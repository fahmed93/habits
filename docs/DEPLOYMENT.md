# Deployment Guide

## GitHub Pages Deployment

This Flutter app is automatically deployed to GitHub Pages whenever code is pushed to the `main` branch.

### Automatic Deployment

The deployment is handled by a GitHub Actions workflow located at `.github/workflows/deploy-gh-pages.yml`.

**Workflow triggers:**
- Automatically on every push to the `main` branch

**Deployment process:**
1. Checks out the code
2. Sets up Flutter 3.38.4 (stable channel)
3. Installs dependencies with `flutter pub get`
4. Builds the web app with `flutter build web --release --base-href "/habits/"`
5. Deploys the built app to the `gh-pages` branch

### Accessing the Deployed App

Once deployed, the app is accessible at:
```
https://fahmed93.github.io/habits/
```

### GitHub Pages Configuration

To enable GitHub Pages for this repository:

1. Go to your repository settings on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select:
   - Branch: `gh-pages`
   - Folder: `/ (root)`
4. Click **Save**

The app will be available at the URL shown in the GitHub Pages section.

### Base URL Configuration

The app is built with `--base-href "/habits/"` to match the GitHub repository name. This ensures proper routing and asset loading when deployed to GitHub Pages.

If you fork this repository or change the repository name, you'll need to update the base-href in `.github/workflows/deploy-gh-pages.yml`:

```yaml
- name: Build Flutter web
  run: flutter build web --release --base-href "/your-repo-name/"
```

### Manual Deployment

If you need to manually deploy the app:

```bash
# Build the web app
flutter build web --release --base-href "/habits/"

# The built files will be in build/web/
# You can manually push these to the gh-pages branch
```

### Deployment Status

You can check the deployment status:
- Go to the **Actions** tab in your GitHub repository
- Look for the "Deploy to GitHub Pages" workflow
- Click on a workflow run to see detailed logs

### Troubleshooting

**App shows 404 errors:**
- Check that the base-href matches your repository name
- Verify GitHub Pages is configured to serve from the `gh-pages` branch

**Deployment fails:**
- Check the workflow logs in the Actions tab
- Ensure all tests pass (the test workflow runs on the same triggers)
- Verify the Flutter version matches the one in the workflow

**Firebase Authentication not working:**
- Add your GitHub Pages domain to Firebase authorized domains
- Go to Firebase Console → Authentication → Settings → Authorized domains
- Add `fahmed93.github.io` to the list
