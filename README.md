# goopy — 하루에 한 장, 감정을 남기는 일력형 메모 앱

goopy는 하루에 단 한 장의 메모만 남길 수 있는 **일력형 감성 다이어리 앱**입니다.  
“오늘의 생각, 기분을 짧게 남기고 싶을 때” — goopy를 열어 기록하세요.

---

## ✨ Features

- 🗓️ **하루 한 장 메모**
  - 날짜(`YYYY-MM-DD`)를 unique key로 저장  
  - 같은 날짜에는 단 한 번만 작성 가능  
- 🎨 **감성적인 타이포 UI**
  - Bold 날짜 + 여백 많은 종이 질감 스타일  
- 🕛 **자동 갱신**
  - 매일 자정(00:00)에 새로운 빈 페이지 생성  
- 📱 **위젯 지원 (WidgetKit)**
  - 오늘 날짜 + 미작성 시 “오늘의 메모 남기기” 버튼 제공  
- 📸 **공유 기능**
  - 오늘의 메모를 이미지로 캡처하여 공유  

---

## 🧩 Tech Stack

| Category | Tech |
|-----------|------|
| UI | SwiftUI |
| Data | SwiftData |
| Widget | WidgetKit, AppIntents |
| Build Target | iOS 17+ |

---

goopy/
┣ 📂 Model/
┃ ┗ DailyEntry.swift          # 하루 한 장 데이터 모델 (SwiftData)
┣ 📂 View/
┃ ┣ ContentView.swift         # 오늘의 페이지 (메인 화면)
┃ ┣ EntryCardView.swift       # 날짜 + 텍스트 카드 UI
┃ ┣ ArchiveView.swift         # 아카이브 / 달력 리스트
┃ ┗ NewEntryView.swift        # 오늘 메모 작성 화면
┣ 📂 Manager/
┃ ┣ NotificationManager.swift # 알림 스케줄러
┃ ┗ DateUtils.swift           # 날짜 유틸 (id, stripToDay 등)
┣ 📂 Widget/
┃ ┣ GoopyWidget.swift         # 위젯 본체
┃ ┣ GoopyEntry.swift          # TimelineEntry
┃ ┗ GoopyIntent.swift         # AppIntent for deep link
┣ 📂 Resources/
┃ ┗ Assets.xcassets           # 폰트, 컬러, 아이콘
┣ 📂 Preview Content/
┃ ┗ SampleData.swift
┣ goopyApp.swift              # @main App, SwiftData 컨테이너
┗ README.md