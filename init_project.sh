#!/usr/bin/env bash

# 사용법:
# ./init_project.sh "My App Name" com.company.myapp my_app
# "앱이름" 번들ID pubspec_name 순서

APP_NAME=$1
BUNDLE_ID=$2
PROJECT_NAME=$3

if [ -z "$APP_NAME" ] || [ -z "$BUNDLE_ID" ] || [ -z "$PROJECT_NAME" ]; then
  echo "❌ 사용법: ./init.sh \"앱이름\" com.company.appname project_name"
  exit 1
fi

echo "🔧 rename 설치"
flutter pub add rename

echo "✏️ 앱 이름 변경"
flutter pub run rename --appname "$APP_NAME"

echo "✏️ 번들 ID 변경"
flutter pub run rename --bundleId "$BUNDLE_ID"

echo "✏️ pubspec name 변경"
sed -i '' "s/^name:.*/name: $PROJECT_NAME/" pubspec.yaml

echo "📁 Android 패키지 구조 변경 시작..."

OLD_DIR=$(find android/app/src/main/kotlin -maxdepth 1 -type d ! -name main ! -name kotlin)
IFS='.' read -ra NEW <<< "$BUNDLE_ID"

NEW_PATH="android/app/src/main/kotlin"
for part in "${NEW[@]}"; do
  NEW_PATH="$NEW_PATH/$part"
done

echo "📁 기존 패키지 폴더: $OLD_DIR"
echo "📁 새로운 패키지 폴더: $NEW_PATH"

mkdir -p "$NEW_PATH"
mv "$OLD_DIR"/* "$NEW_PATH"
rm -rf "$OLD_DIR"

echo "🖋 Kotlin package 선언 변경"
find android/app/src/main/kotlin -type f -name "*.kt" -exec sed -i '' "s/package .*/package $BUNDLE_ID/" {} \;

echo "🧹 flutter clean + pub get"
flutter clean
flutter pub get

echo "🎉 전체 초기 세팅 완료!"