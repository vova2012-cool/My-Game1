# Архитектура Black Red Messenger

## Контекст

Black Red Messenger — это reference-реализация мобильного мессенджера стартап-уровня.

## C4 Level 1 (System Context)

- Пользователь общается с системой через iOS/Android Flutter-клиент.
- Flutter-клиент использует backend API по HTTPS.
- Backend обменивается realtime-событиями по Socket.io.
- Backend хранит данные в MongoDB.
- Backend опционально отправляет push через Firebase Cloud Messaging.
- Backend опционально хранит файлы в Firebase Storage/AWS S3 адаптере.

## C4 Level 2 (Containers)

### Mobile App Container
- UI слой: Material 3 + cyberpunk visual kit.
- State management: Provider + ChangeNotifier.
- API: Dio.
- Socket: socket_io_client.
- Secret storage: flutter_secure_storage.

### API Container
- Express API.
- JWT middleware.
- Multipart image upload.
- Business logic in controllers.
- Services: PushService + StorageService.

### Realtime Container
- Socket.io Server.
- Presence + typing + delivery events.
- Room-per-chat strategy.

### Data Container
- MongoDB (users/chats/messages).

### Notifications Container
- FCM via firebase-admin.

## Domain rules

1. У пользователя должен быть минимум один идентификатор: email или phone.
2. Direct chat уникален для пары пользователей.
3. Group chat имеет title и список admins.
4. Message принадлежит chat и sender.
5. Редактировать/удалять message может только sender.
6. Read receipts хранятся в `readBy[]`.

## Realtime contract

- При подключении socket проходит JWT-auth.
- Клиент отправляет `chat:join` для интересующего чата.
- Отправка сообщения выполняется REST-вызовом.
- Backend затем публикует `message:new` в соответствующую room.

## Security

- Hash passwords: bcrypt.
- JWT auth for REST + Socket handshake.
- Рекомендуется rate limiting и anti-bruteforce middleware.
- Рекомендуется audit log для операций редактирования/удаления.

## Scaling roadmap

- Redis adapter для Socket.io.
- Sharding чатов по tenant/region.
- Media service вынести отдельно.
- Push queue через BullMQ + Redis.
- Search через Elastic/OpenSearch.

## Reliability roadmap

- Retry policy для push.
- Idempotency key для отправки сообщений.
- Outbox pattern для consistency между Mongo и push/event.
- SLO/SLA, мониторинг latency p95/p99.

## DevOps

- Docker compose (Mongo + API).
- CI (lint + test + build).
- CD (blue/green deploy).
- Crash reporting (Sentry/Firebase Crashlytics).
