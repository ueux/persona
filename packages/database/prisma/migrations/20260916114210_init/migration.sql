-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'SUSPENDED', 'DELETED');

-- CreateEnum
CREATE TYPE "AvatarStatus" AS ENUM ('DRAFT', 'ACTIVE', 'ARCHIVED', 'DELETED');

-- CreateEnum
CREATE TYPE "VersionStatus" AS ENUM ('DRAFT', 'TRAINING', 'READY', 'FAILED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "MediaKind" AS ENUM ('IMAGE', 'VIDEO', 'AUDIO');

-- CreateEnum
CREATE TYPE "AssetStatus" AS ENUM ('UPLOADING', 'PROCESSING', 'READY', 'FAILED', 'DELETED');

-- CreateEnum
CREATE TYPE "ConsentScope" AS ENUM ('TRAINING', 'GENERATION', 'COMMERCIAL', 'RESEARCH');

-- CreateEnum
CREATE TYPE "ConsentStatus" AS ENUM ('GRANTED', 'REVOKED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "GenerationKind" AS ENUM ('IMAGE', 'VIDEO', 'AUDIO');

-- CreateEnum
CREATE TYPE "GenerationStatus" AS ENUM ('PENDING', 'QUEUED', 'RUNNING', 'SUCCEEDED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "TrainingStatus" AS ENUM ('PENDING', 'QUEUED', 'RUNNING', 'SUCCEEDED', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "JobPriority" AS ENUM ('LOW', 'NORMAL', 'HIGH', 'URGENT');

-- CreateEnum
CREATE TYPE "AssetProcessingStatus" AS ENUM ('PENDING', 'PROCESSING', 'SUCCEEDED', 'FAILED');

-- CreateEnum
CREATE TYPE "ProviderStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'MAINTENANCE');

-- CreateEnum
CREATE TYPE "ModelStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'DEPRECATED');

-- CreateEnum
CREATE TYPE "AuditAction" AS ENUM ('CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'CONSENT_GRANTED', 'CONSENT_REVOKED', 'GENERATION_STARTED', 'GENERATION_COMPLETED', 'GENERATION_FAILED', 'TRAINING_STARTED', 'TRAINING_COMPLETED', 'EXPORT', 'DOWNLOAD');

-- CreateEnum
CREATE TYPE "AuditResource" AS ENUM ('USER', 'AVATAR', 'AVATAR_VERSION', 'MEDIA_ASSET', 'CONSENT', 'GENERATION', 'TRAINING', 'VOICE_PROFILE', 'PERSONALITY_PROFILE');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "displayName" TEXT,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_identities" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "auth_identities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" TIMESTAMP(3),
    "revokedAt" TIMESTAMP(3),

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "avatars" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "status" "AvatarStatus" NOT NULL DEFAULT 'DRAFT',
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "avatars_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "avatar_versions" (
    "id" TEXT NOT NULL,
    "avatarId" TEXT NOT NULL,
    "version" INTEGER NOT NULL,
    "status" "VersionStatus" NOT NULL DEFAULT 'DRAFT',
    "manifest" JSONB,
    "modelName" TEXT,
    "modelVersion" TEXT,
    "modelProvider" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "avatar_versions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "media_assets" (
    "id" TEXT NOT NULL,
    "avatarId" TEXT NOT NULL,
    "kind" "MediaKind" NOT NULL,
    "status" "AssetStatus" NOT NULL DEFAULT 'UPLOADING',
    "storageKey" TEXT NOT NULL,
    "storageBucket" TEXT,
    "storageProvider" TEXT,
    "originalName" TEXT,
    "mimeType" TEXT NOT NULL,
    "sizeBytes" BIGINT NOT NULL,
    "checksum" TEXT,
    "width" INTEGER,
    "height" INTEGER,
    "durationMs" INTEGER,
    "frameRate" DOUBLE PRECISION,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "media_assets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "asset_processing" (
    "id" TEXT NOT NULL,
    "assetId" TEXT NOT NULL,
    "operation" TEXT NOT NULL,
    "status" "AssetProcessingStatus" NOT NULL DEFAULT 'PENDING',
    "outputKey" TEXT,
    "parameters" JSONB,
    "error" TEXT,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "asset_processing_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "consent_records" (
    "id" TEXT NOT NULL,
    "avatarId" TEXT NOT NULL,
    "scope" "ConsentScope" NOT NULL,
    "status" "ConsentStatus" NOT NULL DEFAULT 'GRANTED',
    "consentVersion" TEXT NOT NULL,
    "signatureHash" TEXT,
    "evidenceKey" TEXT,
    "ipHash" TEXT,
    "userAgentHash" TEXT,
    "grantedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "revokedAt" TIMESTAMP(3),
    "expiresAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "consent_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "voice_profiles" (
    "id" TEXT NOT NULL,
    "avatarVersionId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "provider" TEXT,
    "providerVoiceId" TEXT,
    "language" TEXT,
    "locale" TEXT,
    "configuration" JSONB,
    "sampleAssetId" TEXT,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "voice_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "personality_profiles" (
    "id" TEXT NOT NULL,
    "avatarVersionId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "systemPrompt" TEXT,
    "personalityData" JSONB,
    "tone" TEXT,
    "speakingStyle" TEXT,
    "deliveryStyle" TEXT,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "personality_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "training_jobs" (
    "id" TEXT NOT NULL,
    "avatarVersionId" TEXT NOT NULL,
    "status" "TrainingStatus" NOT NULL DEFAULT 'PENDING',
    "priority" "JobPriority" NOT NULL DEFAULT 'NORMAL',
    "provider" TEXT,
    "externalJobId" TEXT,
    "modelName" TEXT,
    "modelVersion" TEXT,
    "configuration" JSONB,
    "errorCode" TEXT,
    "errorMessage" TEXT,
    "progress" DOUBLE PRECISION,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "training_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "training_inputs" (
    "id" TEXT NOT NULL,
    "trainingJobId" TEXT NOT NULL,
    "assetId" TEXT NOT NULL,
    "role" TEXT,
    "metadata" JSONB,

    CONSTRAINT "training_inputs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_providers" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "status" "ProviderStatus" NOT NULL DEFAULT 'ACTIVE',
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ai_providers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_models" (
    "id" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "version" TEXT,
    "type" "GenerationKind",
    "status" "ModelStatus" NOT NULL DEFAULT 'ACTIVE',
    "capabilities" JSONB,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ai_models_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "generations" (
    "id" TEXT NOT NULL,
    "avatarVersionId" TEXT NOT NULL,
    "providerId" TEXT,
    "modelId" TEXT,
    "kind" "GenerationKind" NOT NULL,
    "status" "GenerationStatus" NOT NULL DEFAULT 'PENDING',
    "priority" "JobPriority" NOT NULL DEFAULT 'NORMAL',
    "prompt" TEXT,
    "negativePrompt" TEXT,
    "parameters" JSONB,
    "metadata" JSONB,
    "externalJobId" TEXT,
    "errorCode" TEXT,
    "errorMessage" TEXT,
    "progress" DOUBLE PRECISION,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "generations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "generation_inputs" (
    "id" TEXT NOT NULL,
    "generationId" TEXT NOT NULL,
    "assetId" TEXT NOT NULL,
    "role" TEXT,
    "metadata" JSONB,

    CONSTRAINT "generation_inputs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "generation_outputs" (
    "id" TEXT NOT NULL,
    "generationId" TEXT NOT NULL,
    "kind" "GenerationKind" NOT NULL,
    "storageKey" TEXT NOT NULL,
    "storageBucket" TEXT,
    "storageProvider" TEXT,
    "mimeType" TEXT,
    "sizeBytes" BIGINT,
    "width" INTEGER,
    "height" INTEGER,
    "durationMs" INTEGER,
    "checksum" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "generation_outputs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "job_attempts" (
    "id" TEXT NOT NULL,
    "generationId" TEXT,
    "trainingJobId" TEXT,
    "attemptNumber" INTEGER NOT NULL,
    "status" TEXT NOT NULL,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "errorCode" TEXT,
    "errorMessage" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "job_attempts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "usage_records" (
    "id" TEXT NOT NULL,
    "generationId" TEXT,
    "providerId" TEXT,
    "modelId" TEXT,
    "inputUnits" DECIMAL(20,6),
    "outputUnits" DECIMAL(20,6),
    "durationMs" INTEGER,
    "cost" DECIMAL(20,8),
    "currency" TEXT DEFAULT 'USD',
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "usage_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "action" "AuditAction" NOT NULL,
    "resource" "AuditResource" NOT NULL,
    "resourceId" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "webhook_events" (
    "id" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "eventType" TEXT NOT NULL,
    "payload" JSONB NOT NULL,
    "processedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "webhook_events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_status_idx" ON "users"("status");

-- CreateIndex
CREATE INDEX "auth_identities_userId_idx" ON "auth_identities"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "auth_identities_provider_providerAccountId_key" ON "auth_identities"("provider", "providerAccountId");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_tokenHash_key" ON "sessions"("tokenHash");

-- CreateIndex
CREATE INDEX "sessions_userId_idx" ON "sessions"("userId");

-- CreateIndex
CREATE INDEX "sessions_expiresAt_idx" ON "sessions"("expiresAt");

-- CreateIndex
CREATE INDEX "avatars_userId_idx" ON "avatars"("userId");

-- CreateIndex
CREATE INDEX "avatars_userId_status_idx" ON "avatars"("userId", "status");

-- CreateIndex
CREATE INDEX "avatar_versions_avatarId_idx" ON "avatar_versions"("avatarId");

-- CreateIndex
CREATE INDEX "avatar_versions_avatarId_status_idx" ON "avatar_versions"("avatarId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "avatar_versions_avatarId_version_key" ON "avatar_versions"("avatarId", "version");

-- CreateIndex
CREATE INDEX "media_assets_avatarId_idx" ON "media_assets"("avatarId");

-- CreateIndex
CREATE INDEX "media_assets_avatarId_kind_idx" ON "media_assets"("avatarId", "kind");

-- CreateIndex
CREATE INDEX "media_assets_status_idx" ON "media_assets"("status");

-- CreateIndex
CREATE INDEX "media_assets_checksum_idx" ON "media_assets"("checksum");

-- CreateIndex
CREATE INDEX "asset_processing_assetId_idx" ON "asset_processing"("assetId");

-- CreateIndex
CREATE INDEX "asset_processing_assetId_operation_idx" ON "asset_processing"("assetId", "operation");

-- CreateIndex
CREATE INDEX "asset_processing_status_idx" ON "asset_processing"("status");

-- CreateIndex
CREATE INDEX "consent_records_avatarId_idx" ON "consent_records"("avatarId");

-- CreateIndex
CREATE INDEX "consent_records_avatarId_scope_idx" ON "consent_records"("avatarId", "scope");

-- CreateIndex
CREATE INDEX "consent_records_status_idx" ON "consent_records"("status");

-- CreateIndex
CREATE INDEX "voice_profiles_avatarVersionId_idx" ON "voice_profiles"("avatarVersionId");

-- CreateIndex
CREATE INDEX "voice_profiles_provider_providerVoiceId_idx" ON "voice_profiles"("provider", "providerVoiceId");

-- CreateIndex
CREATE INDEX "personality_profiles_avatarVersionId_idx" ON "personality_profiles"("avatarVersionId");

-- CreateIndex
CREATE INDEX "training_jobs_avatarVersionId_idx" ON "training_jobs"("avatarVersionId");

-- CreateIndex
CREATE INDEX "training_jobs_status_idx" ON "training_jobs"("status");

-- CreateIndex
CREATE INDEX "training_jobs_provider_externalJobId_idx" ON "training_jobs"("provider", "externalJobId");

-- CreateIndex
CREATE INDEX "training_inputs_trainingJobId_idx" ON "training_inputs"("trainingJobId");

-- CreateIndex
CREATE INDEX "training_inputs_assetId_idx" ON "training_inputs"("assetId");

-- CreateIndex
CREATE UNIQUE INDEX "training_inputs_trainingJobId_assetId_key" ON "training_inputs"("trainingJobId", "assetId");

-- CreateIndex
CREATE UNIQUE INDEX "ai_providers_name_key" ON "ai_providers"("name");

-- CreateIndex
CREATE INDEX "ai_models_providerId_idx" ON "ai_models"("providerId");

-- CreateIndex
CREATE INDEX "ai_models_status_idx" ON "ai_models"("status");

-- CreateIndex
CREATE UNIQUE INDEX "ai_models_providerId_name_version_key" ON "ai_models"("providerId", "name", "version");

-- CreateIndex
CREATE INDEX "generations_avatarVersionId_idx" ON "generations"("avatarVersionId");

-- CreateIndex
CREATE INDEX "generations_status_idx" ON "generations"("status");

-- CreateIndex
CREATE INDEX "generations_providerId_idx" ON "generations"("providerId");

-- CreateIndex
CREATE INDEX "generations_modelId_idx" ON "generations"("modelId");

-- CreateIndex
CREATE INDEX "generations_providerId_externalJobId_idx" ON "generations"("providerId", "externalJobId");

-- CreateIndex
CREATE INDEX "generation_inputs_generationId_idx" ON "generation_inputs"("generationId");

-- CreateIndex
CREATE INDEX "generation_inputs_assetId_idx" ON "generation_inputs"("assetId");

-- CreateIndex
CREATE UNIQUE INDEX "generation_inputs_generationId_assetId_key" ON "generation_inputs"("generationId", "assetId");

-- CreateIndex
CREATE INDEX "generation_outputs_generationId_idx" ON "generation_outputs"("generationId");

-- CreateIndex
CREATE INDEX "job_attempts_generationId_idx" ON "job_attempts"("generationId");

-- CreateIndex
CREATE INDEX "job_attempts_trainingJobId_idx" ON "job_attempts"("trainingJobId");

-- CreateIndex
CREATE UNIQUE INDEX "job_attempts_generationId_attemptNumber_key" ON "job_attempts"("generationId", "attemptNumber");

-- CreateIndex
CREATE UNIQUE INDEX "job_attempts_trainingJobId_attemptNumber_key" ON "job_attempts"("trainingJobId", "attemptNumber");

-- CreateIndex
CREATE INDEX "usage_records_generationId_idx" ON "usage_records"("generationId");

-- CreateIndex
CREATE INDEX "usage_records_providerId_idx" ON "usage_records"("providerId");

-- CreateIndex
CREATE INDEX "usage_records_modelId_idx" ON "usage_records"("modelId");

-- CreateIndex
CREATE INDEX "usage_records_createdAt_idx" ON "usage_records"("createdAt");

-- CreateIndex
CREATE INDEX "audit_logs_userId_idx" ON "audit_logs"("userId");

-- CreateIndex
CREATE INDEX "audit_logs_resource_resourceId_idx" ON "audit_logs"("resource", "resourceId");

-- CreateIndex
CREATE INDEX "audit_logs_createdAt_idx" ON "audit_logs"("createdAt");

-- CreateIndex
CREATE INDEX "webhook_events_provider_idx" ON "webhook_events"("provider");

-- CreateIndex
CREATE INDEX "webhook_events_eventType_idx" ON "webhook_events"("eventType");

-- CreateIndex
CREATE UNIQUE INDEX "webhook_events_provider_eventId_key" ON "webhook_events"("provider", "eventId");

-- AddForeignKey
ALTER TABLE "auth_identities" ADD CONSTRAINT "auth_identities_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "avatars" ADD CONSTRAINT "avatars_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "avatar_versions" ADD CONSTRAINT "avatar_versions_avatarId_fkey" FOREIGN KEY ("avatarId") REFERENCES "avatars"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "media_assets" ADD CONSTRAINT "media_assets_avatarId_fkey" FOREIGN KEY ("avatarId") REFERENCES "avatars"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asset_processing" ADD CONSTRAINT "asset_processing_assetId_fkey" FOREIGN KEY ("assetId") REFERENCES "media_assets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consent_records" ADD CONSTRAINT "consent_records_avatarId_fkey" FOREIGN KEY ("avatarId") REFERENCES "avatars"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "voice_profiles" ADD CONSTRAINT "voice_profiles_avatarVersionId_fkey" FOREIGN KEY ("avatarVersionId") REFERENCES "avatar_versions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "personality_profiles" ADD CONSTRAINT "personality_profiles_avatarVersionId_fkey" FOREIGN KEY ("avatarVersionId") REFERENCES "avatar_versions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "training_jobs" ADD CONSTRAINT "training_jobs_avatarVersionId_fkey" FOREIGN KEY ("avatarVersionId") REFERENCES "avatar_versions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "training_inputs" ADD CONSTRAINT "training_inputs_trainingJobId_fkey" FOREIGN KEY ("trainingJobId") REFERENCES "training_jobs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "training_inputs" ADD CONSTRAINT "training_inputs_assetId_fkey" FOREIGN KEY ("assetId") REFERENCES "media_assets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_models" ADD CONSTRAINT "ai_models_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "ai_providers"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "generations" ADD CONSTRAINT "generations_avatarVersionId_fkey" FOREIGN KEY ("avatarVersionId") REFERENCES "avatar_versions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "generations" ADD CONSTRAINT "generations_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "ai_providers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "generations" ADD CONSTRAINT "generations_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "ai_models"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "generation_inputs" ADD CONSTRAINT "generation_inputs_generationId_fkey" FOREIGN KEY ("generationId") REFERENCES "generations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "generation_inputs" ADD CONSTRAINT "generation_inputs_assetId_fkey" FOREIGN KEY ("assetId") REFERENCES "media_assets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "generation_outputs" ADD CONSTRAINT "generation_outputs_generationId_fkey" FOREIGN KEY ("generationId") REFERENCES "generations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "job_attempts" ADD CONSTRAINT "job_attempts_generationId_fkey" FOREIGN KEY ("generationId") REFERENCES "generations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "job_attempts" ADD CONSTRAINT "job_attempts_trainingJobId_fkey" FOREIGN KEY ("trainingJobId") REFERENCES "training_jobs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "usage_records" ADD CONSTRAINT "usage_records_generationId_fkey" FOREIGN KEY ("generationId") REFERENCES "generations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "usage_records" ADD CONSTRAINT "usage_records_providerId_fkey" FOREIGN KEY ("providerId") REFERENCES "ai_providers"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "usage_records" ADD CONSTRAINT "usage_records_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "ai_models"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
