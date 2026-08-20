# auth_flutter

Flutter frontend for the K7 Auth service.

## Render deployment

This frontend is designed to be deployed as a separate Render web service from the backend API.

### Required backend URL

Set the build-time environment variable before deployment:

- API_BASE_URL=https://your-backend-service.onrender.com

The app uses this value to target the backend instead of the local development URL.

### Render config

Use the included `render.yaml` file in this repository, or create a Docker web service with the `Dockerfile` in this folder.

### Local development

```bash
flutter pub get
flutter run -d chrome
```

If you want to override the backend URL locally, run:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

