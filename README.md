# Black Red Messenger

Стартап-уровневый шаблон мобильного мессенджера в стиле **Telegram-like**, с чёрно-красной киберпанк темой.

## 1) Архитектура системы

```text
Flutter (Android/iOS)
  ├─ Auth / Chats / Dialog / Profile / Settings
  ├─ REST API (Dio)
  ├─ WebSocket (socket.io-client)
  └─ Secure token storage

Node.js + Express API
  ├─ JWT Auth
  ├─ Chat & Message REST endpoints
  ├─ Upload abstraction (S3/Firebase/mock)
  ├─ Socket.io realtime transport
  └─ Push abstraction (Firebase Cloud Messaging)

MongoDB
  ├─ users
  ├─ chats
  └─ messages
```

### Архитектурные слои
- **Mobile**: `core` (сетевой слой, тема, storage, socket), `features` (auth/chat/profile/settings), `shared` (виджеты).
- **Backend**: `config` (env, database, firebase), `models` (MongoDB), `controllers` (бизнес-логика), `routes` (REST), `sockets` (realtime), `services` (push/storage).

---

## 2) Структура папок проекта

```text
.
├── backend/
│   ├── package.json
│   ├── .env.example
│   ├── scripts/
│   │   └── seed.js
│   └── src/
│       ├── app.js
│       ├── server.js
│       ├── config/
│       ├── controllers/
│       ├── middleware/
│       ├── models/
│       ├── routes/
│       ├── services/
│       ├── sockets/
│       └── utils/
├── mobile/
│   ├── pubspec.yaml
│   ├── assets/
│   └── lib/
│       ├── main.dart
│       ├── core/
│       ├── features/
│       └── shared/
└── docs/
```

---

## 3) Модели базы данных (MongoDB)

### User
- `email` / `phone`
- `passwordHash`
- `displayName`
- `avatarUrl`
- `bio`
- `status` (`online/offline/away`)
- `lastSeenAt`
- `fcmTokens[]`

### Chat
- `type` (`direct/group`)
- `title`
- `avatarUrl`
- `members[]`
- `admins[]`
- `pinnedBy[]`
- `lastMessageId`

### Message
- `chatId`
- `senderId`
- `text`
- `attachments[]`
- `editedAt`
- `deletedForEveryone`
- `readBy[]`
- `deliveredTo[]`

---

## 4) REST API

Базовый URL: `http://localhost:8080`

### Auth
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`

### Profile
- `PATCH /api/profile`
- `POST /api/profile/fcm-token`

### Chats
- `GET /api/chats?search=`
- `POST /api/chats/direct`
- `POST /api/chats/group`
- `GET /api/chats/:chatId/messages`
- `POST /api/chats/:chatId/pin`
- `DELETE /api/chats/:chatId/pin`

### Messages
- `POST /api/messages`
- `POST /api/messages/image`
- `PATCH /api/messages/:messageId`
- `DELETE /api/messages/:messageId`
- `POST /api/messages/:messageId/read`

---

## 5) WebSocket сервер (Socket.io)

Events (client -> server):
- `chat:join`
- `chat:leave`
- `typing:start`
- `typing:stop`

Events (server -> client):
- `session:ready`
- `message:new`
- `message:updated`
- `message:deleted`
- `message:read`
- `typing:start`
- `typing:stop`
- `presence:update`

---

## 6) Flutter интерфейс

Реализованные экраны:
1. Splash Screen с красной glow-анимацией.
2. Экран входа/регистрации (email/phone + password).
3. Экран списка чатов с поиском, pin, unread-метками.
4. Экран диалога (incoming/outgoing bubbles, emoji-кнопка, send).
5. Профиль пользователя (имя, статус, аватар).
6. Настройки (уведомления, безопасность, тема, logout).

UI дизайн:
- фон `#0A0A0A`
- surface `#161616`
- accent `#FF1A1A`
- белый текст
- круглые аватары, красные акцентные границы

---

## 7) Система сообщений

- отправка текстовых сообщений
- отправка изображений через `/api/messages/image`
- редактирование / удаление сообщений
- read receipts (`message:read`)
- typing-индикатор (`typing:start|stop`)
- мгновенная доставка через Socket.io rooms

---

## 8) Push-уведомления (FCM)

- Backend умеет работать в 2 режимах:
  - **real mode**: Firebase Admin SDK
  - **mock mode**: логирует отправку в консоль
- Мобильный клиент может регистрировать FCM token (`/api/profile/fcm-token`).
- При оффлайн-получателе отправляется push с payload (`chatId`, `messageId`).

> Для активации Firebase нужно заполнить переменные в `backend/.env`.

---

## 9) Инструкции сборки APK

```bash
cd mobile
flutter pub get
flutter build apk --release \
  --dart-define=API_BASE=http://<YOUR_BACKEND_HOST>:8080 \
  --dart-define=SOCKET_BASE=http://<YOUR_BACKEND_HOST>:8080
```

APK после сборки:
- `mobile/build/app/outputs/flutter-apk/app-release.apk`

Для debug-эмулятора Android обычно backend доступен по `10.0.2.2`.

---

## 10) Инструкции запуска backend сервера

### Требования
- Node.js 20+
- MongoDB 6+

### Запуск
```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

### Опционально: seed демо-данных
```bash
cd backend
npm run seed
```

### Проверка health
```bash
curl http://localhost:8080/health
```

---

## Быстрый старт end-to-end

1. Поднять MongoDB.
2. Запустить backend (`npm run dev`).
3. Запустить Flutter app:
   ```bash
   cd mobile
   flutter pub get
   flutter run \
     --dart-define=API_BASE=http://10.0.2.2:8080 \
     --dart-define=SOCKET_BASE=http://10.0.2.2:8080
   ```
4. Зарегистрировать 2 пользователей и начать диалог.

---

## Production рекомендации

- Добавить refresh token flow.
- Подключить реальный S3/Firebase Storage upload adapter.
- Реализовать end-to-end encryption слой.
- Ввести CQRS/read-model для масштабирования чатов.
- Настроить observability: OpenTelemetry + централизованные логи.
- Добавить CI/CD (lint/test/build APK + deploy backend).
