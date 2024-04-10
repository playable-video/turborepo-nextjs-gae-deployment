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
- [Usage](#usage)
  - [Basic Example](#basic-example)
  - [Advanced Example](#advanced-example)

## Features

- **Customizable App and Directory Selection**: Deploy any app within your TurboRepo by specifying its directory.
- **Conditional Promotion**: Opt to promote the deployed version to receive all traffic.
- **Custom `.gcloudignore` and `app.yaml` Configuration**: Use your own `.gcloudignore` and `app.yaml` files or let the action generate defaults.
- **Efficient Dependency Management**: Utilizes Turbo CLI and yarn for fast and reliable builds.
- **Version Autonaming**: Optionally, autoname Google App Engine project versions with the branch name, facilitating easy identification and management.

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

| Name                  | Description                                                                                   | Required | Default  |
|-----------------------|-----------------------------------------------------------------------------------------------|----------|----------|
| `apps_directory`      | The directory where all monorepo apps are stored, relative to the root.                       | No       | `apps`   |
| `target_app`          | The name of the app to deploy, corresponding to its directory name within the monorepo.       | Yes      |          |
| `gcloud_project_id`   | The Google Cloud project ID.                                                                  | Yes      |          |
| `gcloud_service_id`   | The Google App Engine service ID to which the app will be deployed.                           | No       | `default`|
| `gcloud_key_json`     | The minified single-line JSON string of the Google Cloud service account key.                 | Yes      |          |
| `should_promote`      | Whether to promote the deployed version to receive all traffic.                               | No       | `false`  |
| `autoname_version`    | Whether to autoname the version based on the branch name.                                     | No       |          |
| `gcloudignore_path`   | Path to a custom `.gcloudignore` file.                                                        | No       |          |
| `app_yaml_path`       | Path to a custom `app.yaml` file.                                                             | No       |          |

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
          cache: 'yarn'

      - name: Install Dependencies
        shell: bash
        run: |
          yarn global add turbo
          yarn --prefer-offline  

      - name: Deploy to Google App Engine 🚀
        uses: playable-video/turborepo-nextjs-gae-deployment@v1
        with:
          target_app: my-app
          gcloud_project_id: ${{ vars.GCLOUD_PROJECT_ID }}
          gcloud_key_json: ${{ secrets.GCLOUD_KEY_JSON }}

```

### Advanced Example

Here is a demonstration of how you can deploy an app with custom `.gcloudignore` and `app.yaml` configuration files, specifying a non-default apps directory, and opt to promote the app version to receive all traffic immediately upon deployment. This setup is ideal for scenarios where you have a more complex monorepo structure or need specific deployment configurations for your Google App Engine project.

In this example, the app is located at `services/custom-nextjs-app` and all versions will be named after the branch that the action is triggered in.

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
          cache: 'yarn'

      - name: Install Dependencies
        shell: bash
        run: |
          yarn global add turbo
          yarn --prefer-offline  

      - name: Deploy to Google App Engine with Custom Configs 🚀
        uses: playable-video/turborepo-nextjs-gae-deployment@v1
        with:
          apps_directory: 'services'
          target_app: 'custom-nextjs-app'
          gcloud_project_id: ${{ vars.GCLOUD_PROJECT_ID }}
          gcloud_service_id: 'frontend'
          gcloud_key_json: ${{ secrets.GCLOUD_KEY_JSON }}
          should_promote: true
          gcloudignore_path: 'configs/custom-nextjs-app/.gcloudignore'
          app_yaml_path: 'configs/custom-nextjs-app/app.yaml'
          autoname_version: true

```

In this example, if you push from the `new-feature` branch, you will have a `new-feature` version when you view your project's versions in the Google Cloud
Console. 

Because the version name and the branch name are the same, this allows you to automatically delete your deployments in a separate workflow upon a branch being deleted.
Here's an example of a workflow that would achieve this and print a summary of all of the versions deleted (as well as which services they came from).

```yaml
# workflows/gcloud_clean.yml

name: 'Clean-up Deployments'

on:
  delete:
    # This ensures the workflow runs only for branch deletions, not tags
    branches:
      - '**'

jobs:
  gcloud-clean:
    runs-on: ubuntu-latest
    environment: development
    if: ${{ github.event.ref_type == 'branch' }}
    steps:
      - name: Authenticate with Google Cloud
        uses: google-github-actions/auth@v2
        with:
          project_id: ${{ vars.GCLOUD_PROJECT_ID }}
          credentials_json: ${{ secrets.GCLOUD_KEY_JSON }}

      - name: Set up Google Cloud SDK ☁️
        uses: google-github-actions/setup-gcloud@v2
        with:
          project_id: ${{ vars.GCLOUD_PROJECT_ID }}

      - name: Fetch Matching App Engine Versions
        shell: bash
        id: fetch-versions
        run: |
          BRANCH_NAME="${{ github.event.ref }}"
          echo "## Cleaning up deployments for branch: $BRANCH_NAME"

          VERSIONS=$(gcloud app versions list --format="value(version.id,service)" --filter="version.id=$BRANCH_NAME" --project=${{ vars.GCLOUD_PROJECT_ID }})

          if [[ -z "$VERSIONS" ]]; then
            echo "No matching versions found for branch: $BRANCH_NAME" >> $GITHUB_STEP_SUMMARY
          else
            echo "Found matching versions for branch: $BRANCH_NAME" >> $GITHUB_STEP_SUMMARY

            echo "$VERSIONS" | while IFS= read -r line; do
              VERSION_ID=$(echo "$line" | awk '{print $1}')
              SERVICE_NAME=$(echo "$line" | awk '{print $2}')

              echo "Deleting version: $VERSION_ID of service: $SERVICE_NAME"
              gcloud app versions delete "$VERSION_ID" --service="$SERVICE_NAME" --quiet --project=${{ vars.GCLOUD_PROJECT_ID }}

              echo "- $SERVICE_NAME/$VERSION_ID" >> $GITHUB_STEP_SUMMARY
            done
          fi

```
