#!/usr/bin/env bash

# 사용법:
# ./init.sh "My App Name" com.company.myapp my_app

APP_NAME=$1
BUNDLE_ID=$2
PROJECT_NAME=$3

if [ -z "$APP_NAME" ] || [ -z "$BUNDLE_ID" ] || [ -z "$PROJECT_NAME" ]; then
  echo "❌ 사용법: ./init.sh \"앱이름\" com.company.appname project_folder_name"
  echo "예: ./init.sh \"My App\" com.mycompany.myapp my_app"
  exit 1
fi

echo "🔧 앱 초기 세팅 시작..."

echo "📦 rename 패키지 설치"
flutter pub add rename

echo "✏️ 앱 이름 변경: $APP_NAME"
flutter pub run rename --appname "$APP_NAME"

echo "✏️ 번들 ID 변경: $BUNDLE_ID"
flutter pub run rename --bundleId "$BUNDLE_ID"

echo "✏️ pubspec.yaml의 name 변경: $PROJECT_NAME"
sed -i '' "s/^name:.*/name: $PROJECT_NAME/" pubspec.yaml

echo "🧹 flutter clean & pub get"
flutter clean
flutter pub get

echo "🎉 완료!"
echo "앱 이름: $APP_NAME"
echo "번들 ID: $BUNDLE_ID"
echo "pubspec name: $PROJECT_NAME"
echo "이제 개발을 시작하세요!"