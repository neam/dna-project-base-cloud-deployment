<?php

namespace neam\bootstrap;

use Exception;

// Optionally include a identity file containing identity-related deployment defaults

$path = dirname(__FILE__) . DIRECTORY_SEPARATOR . 'identity.php';
if (is_readable($path)) {
    require($path);
}

// Non-versioned secrets

$_ENV["SAUCE_ACCESS_KEY"] = "";
$_ENV["SAUCE_USERNAME"] = "";

$_ENV["USER_DATA_BACKUP_UPLOADERS_ACCESS_KEY"] = "";
$_ENV["USER_DATA_BACKUP_UPLOADERS_SECRET"] = "";
$_ENV["PUBLIC_FILE_UPLOADERS_ACCESS_KEY"] = "";
$_ENV["PUBLIC_FILE_UPLOADERS_SECRET"] = "";
$_ENV["PUBLIC_FILES_S3_BUCKET"] = "s3://files.example.com";
$_ENV["PUBLIC_FILES_S3_REGION"] = "us-standard";
$_ENV["PUBLIC_FILES_S3_PATH"] = "";
$_ENV["PUBLIC_FILES_HTTP_HOST"] = "files.example.com";
$_ENV["CDN_S3_BUCKET"] = "";
$_ENV["CDN_S3_PATH"] = "/" . Config::read("APPVHOST", null, $required = true) . "/";
$_ENV["CDN_PATH_HTTP"] = "http://static.example.com" . Config::read("CDN_S3_PATH", null, $required = true);
$_ENV["CDN_PATH_HTTPS"] = "https://static.example.com" . Config::read("CDN_S3_PATH", null, $required = true);

$_ENV["COMPOSER_GITHUB_TOKEN"] = "";
$_ENV["NEW_RELIC_LICENSE_KEY"] = "";

// Filestack (previously Filepicker)
$_ENV["FILESTACK_API_KEY"] = "";
$_ENV["FILESTACK_API_SECRET"] = "";

// Auth0
$_ENV["AUTH0_APPS"] = "";
$_ENV["AUTH0_CLIENT_IDS"] = "";
$_ENV["AUTH0_CLIENT_SECRETS"] = "";
$_ENV["CORS_ACL_ORIGIN_HOSTS"] = "localhost:9000,app.example.com";

// Sentry
$_ENV["SENTRY_DSN"] = "";

// Deployment-specifics
$_ENV['WEB_SERVER_POSIX_USER'] = "www-data";
$_ENV['WEB_SERVER_POSIX_GROUP'] = "www-data";

// Smtp url
if (Config::read("DEPLOY_STABILITY_TAG") === "prod") {
    $_ENV["SMTP_HOST"] = $_ENV["PRODUCTION_SMTP_HOST"];
    $_ENV["SMTP_PORT"] = $_ENV["PRODUCTION_SMTP_PORT"];
    $_ENV["SMTP_USERNAME"] = $_ENV["PRODUCTION_SMTP_USERNAME"];
    $_ENV["SMTP_PASSWORD"] = $_ENV["PRODUCTION_SMTP_PASSWORD"];
    $_ENV["SMTP_ENCRYPTION"] = $_ENV["PRODUCTION_SMTP_ENCRYPTION"];
    $_ENV["GA_TRACKING_ID"] = $_ENV["DEVELOPMENT_GA_TRACKING_ID"];
} else {
    $_ENV["SMTP_HOST"] = $_ENV["DEVELOPMENT_SMTP_HOST"];
    $_ENV["SMTP_PORT"] = $_ENV["DEVELOPMENT_SMTP_PORT"];
    $_ENV["SMTP_USERNAME"] = $_ENV["DEVELOPMENT_SMTP_USERNAME"];
    $_ENV["SMTP_PASSWORD"] = $_ENV["DEVELOPMENT_SMTP_PASSWORD"];
    $_ENV["SMTP_ENCRYPTION"] = $_ENV["DEVELOPMENT_SMTP_ENCRYPTION"];
    $_ENV["GA_TRACKING_ID"] = $_ENV["DEVELOPMENT_GA_TRACKING_ID"];
}

// Amazon RDS db access details
if (Config::read("DEPLOY_STABILITY_TAG") === "dev") {
    $_ENV["DATABASE_HOST"] = $_ENV["DEV_DATABASE_HOST"];
    $_ENV["DATABASE_PORT"] = $_ENV["DEV_DATABASE_PORT"];
    $_ENV["DATABASE_PASSWORD"] = $_ENV["DEV_DATABASE_PASSWORD"];
    $_ENV["DATABASE_ROOT_USER"] = $_ENV["DEV_DATABASE_ROOT_USER"];
    $_ENV["DATABASE_ROOT_PASSWORD"] = $_ENV["DEV_DATABASE_ROOT_PASSWORD"];
} elseif (Config::read("DEPLOY_STABILITY_TAG") === "demo") {
    $_ENV["DATABASE_HOST"] = $_ENV["DEMO_DATABASE_HOST"];
    $_ENV["DATABASE_PORT"] = $_ENV["DEMO_DATABASE_PORT"];
    $_ENV["DATABASE_PASSWORD"] = $_ENV["DEMO_DATABASE_PASSWORD"];
    $_ENV["DATABASE_ROOT_USER"] = $_ENV["DEMO_DATABASE_ROOT_USER"];
    $_ENV["DATABASE_ROOT_PASSWORD"] = $_ENV["DEMO_DATABASE_ROOT_PASSWORD"];
} elseif (Config::read("DEPLOY_STABILITY_TAG") === "prod") {
    $_ENV["DATABASE_HOST"] = $_ENV["PROD_DATABASE_HOST"];
    $_ENV["DATABASE_PORT"] = $_ENV["PROD_DATABASE_PORT"];
    $_ENV["DATABASE_PASSWORD"] = $_ENV["PROD_DATABASE_PASSWORD"];
    $_ENV["DATABASE_ROOT_USER"] = $_ENV["PROD_DATABASE_ROOT_USER"];
    $_ENV["DATABASE_ROOT_PASSWORD"] = $_ENV["PROD_DATABASE_ROOT_PASSWORD"];
}

// Shared application data database configuration
$_ENV["SHARED_APPLICATION_DATA_DATABASE_HOST"] = $_ENV["DATABASE_HOST"];
$_ENV["SHARED_APPLICATION_DATA_DATABASE_PORT"] = $_ENV["DATABASE_PORT"];
$_ENV["SHARED_APPLICATION_DATA_DATABASE_NAME"] = 'db_' . str_replace("-", "_", 'motin');
$_ENV["SHARED_APPLICATION_DATA_DATABASE_USER"] = substr(md5($_ENV['SHARED_APPLICATION_DATA_DATABASE_NAME']), 0, 16);
$_ENV["SHARED_APPLICATION_DATA_DATABASE_PASSWORD"] = $_ENV["PROD_DATABASE_PASSWORD"];
