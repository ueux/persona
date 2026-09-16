/*
  Warnings:

  - The values [QUEUED] on the enum `GenerationStatus` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the column `manifest` on the `avatar_versions` table. All the data in the column will be lost.
  - You are about to drop the column `modelName` on the `avatar_versions` table. All the data in the column will be lost.
  - You are about to drop the column `modelProvider` on the `avatar_versions` table. All the data in the column will be lost.
  - You are about to drop the column `modelVersion` on the `avatar_versions` table. All the data in the column will be lost.
  - You are about to drop the column `deletedAt` on the `avatars` table. All the data in the column will be lost.
  - You are about to drop the column `metadata` on the `avatars` table. All the data in the column will be lost.
  - You are about to drop the column `status` on the `avatars` table. All the data in the column will be lost.
  - You are about to drop the column `consentVersion` on the `consent_records` table. All the data in the column will be lost.
  - You are about to drop the column `evidenceKey` on the `consent_records` table. All the data in the column will be lost.
  - You are about to drop the column `expiresAt` on the `consent_records` table. All the data in the column will be lost.
  - You are about to drop the column `ipHash` on the `consent_records` table. All the data in the column will be lost.
  - You are about to drop the column `signatureHash` on the `consent_records` table. All the data in the column will be lost.
  - You are about to drop the column `status` on the `consent_records` table. All the data in the column will be lost.
  - You are about to drop the column `userAgentHash` on the `consent_records` table. All the data in the column will be lost.
  - You are about to drop the column `metadata` on the `generation_inputs` table. All the data in the column will be lost.
  - You are about to drop the column `errorCode` on the `generations` table. All the data in the column will be lost.
  - You are about to drop the column `errorMessage` on the `generations` table. All the data in the column will be lost.
  - You are about to drop the column `externalJobId` on the `generations` table. All the data in the column will be lost.
  - You are about to drop the column `metadata` on the `generations` table. All the data in the column will be lost.
  - You are about to drop the column `modelId` on the `generations` table. All the data in the column will be lost.
  - You are about to drop the column `negativePrompt` on the `generations` table. All the data in the column will be lost.
  - You are about to drop the column `priority` on the `generations` table. All the data in the column will be lost.
  - You are about to drop the column `progress` on the `generations` table. All the data in the column will be lost.
  - You are about to drop the column `providerId` on the `generations` table. All the data in the column will be lost.
  - You are about to drop the column `deletedAt` on the `media_assets` table. All the data in the column will be lost.
  - You are about to drop the column `durationMs` on the `media_assets` table. All the data in the column will be lost.
  - You are about to drop the column `frameRate` on the `media_assets` table. All the data in the column will be lost.
  - You are about to drop the column `height` on the `media_assets` table. All the data in the column will be lost.
  - You are about to drop the column `metadata` on the `media_assets` table. All the data in the column will be lost.
  - You are about to drop the column `originalName` on the `media_assets` table. All the data in the column will be lost.
  - You are about to drop the column `status` on the `media_assets` table. All the data in the column will be lost.
  - You are about to drop the column `storageBucket` on the `media_assets` table. All the data in the column will be lost.
  - You are about to drop the column `storageProvider` on the `media_assets` table. All the data in the column will be lost.
  - You are about to drop the column `width` on the `media_assets` table. All the data in the column will be lost.
  - You are about to alter the column `sizeBytes` on the `media_assets` table. The data in that column could be lost. The data in that column will be cast from `BigInt` to `Integer`.
  - You are about to drop the column `deletedAt` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `displayName` on the `users` table. All the data in the column will be lost.
  - You are about to drop the column `status` on the `users` table. All the data in the column will be lost.
  - You are about to drop the `ai_models` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `ai_providers` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `asset_processing` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `audit_logs` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `auth_identities` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `generation_outputs` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `job_attempts` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `personality_profiles` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `sessions` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `training_inputs` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `training_jobs` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `usage_records` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `voice_profiles` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `webhook_events` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `granted` to the `consent_records` table without a default value. This is not possible if the table is not empty.
  - Added the required column `signature` to the `consent_records` table without a default value. This is not possible if the table is not empty.
  - Made the column `parameters` on table `generations` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "GenerationStatus_new" AS ENUM ('PENDING', 'RUNNING', 'SUCCEEDED', 'FAILED', 'CANCELLED');
ALTER TABLE "public"."generations" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "generations" ALTER COLUMN "status" TYPE "GenerationStatus_new" USING ("status"::text::"GenerationStatus_new");
ALTER TYPE "GenerationStatus" RENAME TO "GenerationStatus_old";
ALTER TYPE "GenerationStatus_new" RENAME TO "GenerationStatus";
DROP TYPE "public"."GenerationStatus_old";
ALTER TABLE "generations" ALTER COLUMN "status" SET DEFAULT 'PENDING';
COMMIT;

-- DropForeignKey
ALTER TABLE "ai_models" DROP CONSTRAINT "ai_models_providerId_fkey";

-- DropForeignKey
ALTER TABLE "asset_processing" DROP CONSTRAINT "asset_processing_assetId_fkey";

-- DropForeignKey
ALTER TABLE "audit_logs" DROP CONSTRAINT "audit_logs_userId_fkey";

-- DropForeignKey
ALTER TABLE "auth_identities" DROP CONSTRAINT "auth_identities_userId_fkey";

-- DropForeignKey
ALTER TABLE "generation_outputs" DROP CONSTRAINT "generation_outputs_generationId_fkey";

-- DropForeignKey
ALTER TABLE "generations" DROP CONSTRAINT "generations_modelId_fkey";

-- DropForeignKey
ALTER TABLE "generations" DROP CONSTRAINT "generations_providerId_fkey";

-- DropForeignKey
ALTER TABLE "job_attempts" DROP CONSTRAINT "job_attempts_generationId_fkey";

-- DropForeignKey
ALTER TABLE "job_attempts" DROP CONSTRAINT "job_attempts_trainingJobId_fkey";

-- DropForeignKey
ALTER TABLE "personality_profiles" DROP CONSTRAINT "personality_profiles_avatarVersionId_fkey";

-- DropForeignKey
ALTER TABLE "sessions" DROP CONSTRAINT "sessions_userId_fkey";

-- DropForeignKey
ALTER TABLE "training_inputs" DROP CONSTRAINT "training_inputs_assetId_fkey";

-- DropForeignKey
ALTER TABLE "training_inputs" DROP CONSTRAINT "training_inputs_trainingJobId_fkey";

-- DropForeignKey
ALTER TABLE "training_jobs" DROP CONSTRAINT "training_jobs_avatarVersionId_fkey";

-- DropForeignKey
ALTER TABLE "usage_records" DROP CONSTRAINT "usage_records_generationId_fkey";

-- DropForeignKey
ALTER TABLE "usage_records" DROP CONSTRAINT "usage_records_modelId_fkey";

-- DropForeignKey
ALTER TABLE "usage_records" DROP CONSTRAINT "usage_records_providerId_fkey";

-- DropForeignKey
ALTER TABLE "voice_profiles" DROP CONSTRAINT "voice_profiles_avatarVersionId_fkey";

-- DropIndex
DROP INDEX "avatar_versions_avatarId_status_idx";

-- DropIndex
DROP INDEX "avatars_userId_status_idx";

-- DropIndex
DROP INDEX "consent_records_avatarId_scope_idx";

-- DropIndex
DROP INDEX "consent_records_status_idx";

-- DropIndex
DROP INDEX "generations_modelId_idx";

-- DropIndex
DROP INDEX "generations_providerId_externalJobId_idx";

-- DropIndex
DROP INDEX "generations_providerId_idx";

-- DropIndex
DROP INDEX "media_assets_avatarId_kind_idx";

-- DropIndex
DROP INDEX "media_assets_checksum_idx";

-- DropIndex
DROP INDEX "media_assets_status_idx";

-- DropIndex
DROP INDEX "users_status_idx";

-- AlterTable
ALTER TABLE "avatar_versions" DROP COLUMN "manifest",
DROP COLUMN "modelName",
DROP COLUMN "modelProvider",
DROP COLUMN "modelVersion";

-- AlterTable
ALTER TABLE "avatars" DROP COLUMN "deletedAt",
DROP COLUMN "metadata",
DROP COLUMN "status";

-- AlterTable
ALTER TABLE "consent_records" DROP COLUMN "consentVersion",
DROP COLUMN "evidenceKey",
DROP COLUMN "expiresAt",
DROP COLUMN "ipHash",
DROP COLUMN "signatureHash",
DROP COLUMN "status",
DROP COLUMN "userAgentHash",
ADD COLUMN     "granted" BOOLEAN NOT NULL,
ADD COLUMN     "signature" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "generation_inputs" DROP COLUMN "metadata";

-- AlterTable
ALTER TABLE "generations" DROP COLUMN "errorCode",
DROP COLUMN "errorMessage",
DROP COLUMN "externalJobId",
DROP COLUMN "metadata",
DROP COLUMN "modelId",
DROP COLUMN "negativePrompt",
DROP COLUMN "priority",
DROP COLUMN "progress",
DROP COLUMN "providerId",
ADD COLUMN     "error" TEXT,
ALTER COLUMN "parameters" SET NOT NULL,
ALTER COLUMN "parameters" SET DEFAULT '{}';

-- AlterTable
ALTER TABLE "media_assets" DROP COLUMN "deletedAt",
DROP COLUMN "durationMs",
DROP COLUMN "frameRate",
DROP COLUMN "height",
DROP COLUMN "metadata",
DROP COLUMN "originalName",
DROP COLUMN "status",
DROP COLUMN "storageBucket",
DROP COLUMN "storageProvider",
DROP COLUMN "width",
ALTER COLUMN "sizeBytes" SET DATA TYPE INTEGER;

-- AlterTable
ALTER TABLE "users" DROP COLUMN "deletedAt",
DROP COLUMN "displayName",
DROP COLUMN "status";

-- DropTable
DROP TABLE "ai_models";

-- DropTable
DROP TABLE "ai_providers";

-- DropTable
DROP TABLE "asset_processing";

-- DropTable
DROP TABLE "audit_logs";

-- DropTable
DROP TABLE "auth_identities";

-- DropTable
DROP TABLE "generation_outputs";

-- DropTable
DROP TABLE "job_attempts";

-- DropTable
DROP TABLE "personality_profiles";

-- DropTable
DROP TABLE "sessions";

-- DropTable
DROP TABLE "training_inputs";

-- DropTable
DROP TABLE "training_jobs";

-- DropTable
DROP TABLE "usage_records";

-- DropTable
DROP TABLE "voice_profiles";

-- DropTable
DROP TABLE "webhook_events";

-- DropEnum
DROP TYPE "AssetProcessingStatus";

-- DropEnum
DROP TYPE "AssetStatus";

-- DropEnum
DROP TYPE "AuditAction";

-- DropEnum
DROP TYPE "AuditResource";

-- DropEnum
DROP TYPE "AvatarStatus";

-- DropEnum
DROP TYPE "ConsentStatus";

-- DropEnum
DROP TYPE "JobPriority";

-- DropEnum
DROP TYPE "ModelStatus";

-- DropEnum
DROP TYPE "ProviderStatus";

-- DropEnum
DROP TYPE "TrainingStatus";

-- DropEnum
DROP TYPE "UserStatus";
