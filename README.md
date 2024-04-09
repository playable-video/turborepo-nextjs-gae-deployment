# turborepo-nextjs-gae-deployment

This GitHub Action automates the deployment of a [TurboRepo](https://turbo.build/) [NextJS](https://nextjs.org/) application to [Google App Engine](https://cloud.google.com/appengine?hl=en), leveraging a flexible [Node.js](https://nodejs.org/en) runtime and [yarn](https://yarnpkg.com/) for dependency management. It's designed to work seamlessly with monorepo setups and provides flexibility in deployment configuration.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
  - [NextJS Configuration](#nextjs-configuration)
  - [Enable App Engine APIs](#enable-app-engine-apis)
  - [Verify or Create an App Engine Application](#verify-or-create-an-app-engine-application)
  - [Service Account Permissions](#service-account-permissions)
  - [Creating Google Cloud Service Account Key](#creating-google-cloud-service-account-key)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Usage](#usage)
  - [Basic Example](#basic-example)
  - [Advanced Example](#advanced-example)

## Features

- **Customizable App and Directory Selection**: Deploy any app within your TurboRepo by specifying its directory.
- **Conditional Promotion**: Choose whether to promote the deployed version to receive all traffic.
- **Custom `.gcloudignore` and `app.yaml` Support**: Use your own configuration files or let the action generate defaults for you.
- **Efficient Dependency Installation**: Turbo CLI and yarn ensure fast and reliable builds.

## Prerequisites

Before deploying your application to Google App Engine using this GitHub Action, ensure the following prerequisites are met:

### NextJS Configuration

By default, Next.js outputs the build files to the .next directory. However, for our deployment process, we require the build files to be located in a build directory. This configuration can be achieved by setting the `distDir` option in your `next.config.js` file.

```javascript
// next.config.js
module.exports = {
  // Specify the directory where Next.js will output the build files
  distDir: 'build',
  // Other configurations...
};
```

### Enable App Engine APIs

Your Google Cloud project must have the **App Engine API** and **App Engine Flexible Environment API** enabled. These APIs allow you to deploy and manage your applications on Google App Engine. Follow these steps to enable them:

1. **Go to the Google Cloud Console:** Navigate to the [Google Cloud Console](https://console.cloud.google.com/).
2. **Select your project:** Ensure the correct Google Cloud project is selected at the top of the console.
3. **Access the API Library:** From the navigation menu (☰), go to `APIs & Services > Library`.
4. **Search for the App Engine APIs:**
    * In the search bar, type `App Engine Admin API` and select it from the list. Click the Enable button to enable this API for your project.
    * Repeat the process for the `App Engine Flexible Environment API` by searching for it and clicking Enable.

### Verify or Create an App Engine Application

If you haven't already, you need to create an App Engine application within your project. This can be done through the [Google Cloud Console](https://console.cloud.google.com/):

1. **Navigate to App Engine**: In the Google Cloud Console, go to App Engine.
2. **Create Application:** If no application exists for your project, you'll be prompted to create one. Select the region that suits you best and follow the instructions to create the application.

### Service Account Permissions

Ensure the service account used for deployment has appropriate roles assigned for App Engine operations, typically the `App Engine Admin` role. This allows the service account to deploy applications and manage App Engine settings.

### Creating Google Cloud Service Account Key

To authenticate with Google Cloud, you need a service account key. Here's how to create one:

1. **Navigate to IAM & Admin**: In the Google Cloud Console, go to `IAM & Admin > Service Accounts` ([link for shortcut](https://console.cloud.google.com/iam-admin/serviceaccounts))
2. **Create or Select a Service Account**: You can create a new service account or select an existing one. Ensure the service account has the necessary permissions for App Engine deployment. Typically, the `App Engine Admin` role is sufficient.
3. **Generate a New Key**: With the service account selected, navigate to the `Keys` tab and choose `Add Key` > `Create new key`. Select `JSON` as the key type and click `Create`. This downloads the key to your computer.
4. **Minify and Store the Key**: Minify the JSON key file to a single line. You can use online tools or run a command like `jq -c . < your-key-file.json`. Store this minified string as a secret in your GitHub repository (Settings > Secrets).

### Conclusion
Meeting these prerequisites ensures your GitHub Actions workflow can deploy applications to Google App Engine without encountering permissions or API limitations. This setup is a one-time process per Google Cloud project and doesn't need to be repeated for subsequent deployments.

## Inputs

| Name                 | Description                                                                                   | Required | Default  |
|----------------------|-----------------------------------------------------------------------------------------------|----------|----------|
| `apps_directory`     | Directory where all monorepo apps are stored, relative to the root.                           | No       | `apps`   |
| `target_app`         | Name of the app to deploy (should be the same as its apps/ directory)                         | Yes      |       |
| `gcloud_project_id`         | Google Cloud project ID.                                                                      | Yes      |       |
| `should_promote`     | Whether to promote the app (route all traffic to the new version).                            | No       | `false`  |
| `gcloudignore_path`  | Custom path to a `.gcloudignore` file.                                                        | No       |       |
| `app_yaml_path`      | Custom path to an `app.yaml` file.                                                            | No       |      |
| `gcloud_key_json`| Service account key for Google Cloud authentication, as a minified single-line JSON string.   | Yes      |       |

## Outputs

| Name            | Description                                  |
|-----------------|----------------------------------------------|
| `deployment_url`| The URL of the deployed app on Google App Engine. |

## Usage

### Basic Example

Here's a basic example of how you can use this action in your workflow. In this case, you are deploying an app located in `apps/my-app`, using the default gcloud configuration files (which are auto-generated by this action), and will only need to fill in the required inputs.

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Dependencies
        run: |
          yarn global add turbo
          yarn install
      
      - name: Deploy to Google App Engine 🚀
        uses: playable-video/turborepo-nextjs-gae-deployment@v1
        with:
          target_app: my-app
          gcloud_project_id: ${{ secrets.GCP_PROJECT_ID }}
          gcloud_key_json: ${{ secrets.GCP_SA_KEY }}
```

### Advanced Example

Here is a demonstration of how you can deploy an app with custom `.gcloudignore` and `app.yaml` configuration files, specifying a non-default apps directory, and opt to promote the app version to receive all traffic immediately upon deployment. This setup is ideal for scenarios where you have a more complex monorepo structure or need specific deployment configurations for your Google App Engine project.

In this example, the app is located at `services/custom-nextjs-app`.

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Dependencies
        run: |
          yarn global add turbo
          yarn install
      
      - name: Deploy to Google App Engine with Custom Configs 🚀
        uses: playable-video/turborepo-nextjs-gae-deployment@v1
        with:
          apps_directory: 'services'
          target_app: 'custom-nextjs-app'
          gcloud_project_id: ${{ secrets.GCP_PROJECT_ID }}
          gcloud_service_id: 'frontend'
          gcloud_key_json: ${{ secrets.GCP_SA_KEY }}
          should_promote: true
          gcloudignore_path: 'configs/custom-nextjs-app/.gcloudignore'
          app_yaml_path: 'configs/custom-nextjs-app/app.yaml'
```
