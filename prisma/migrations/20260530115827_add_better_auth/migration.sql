-- CreateEnum
CREATE TYPE "assignment_status" AS ENUM ('draft', 'published', 'closed', 'archived');

-- CreateEnum
CREATE TYPE "attachment_category" AS ENUM ('assignment_question', 'assignment_submission', 'summary_source', 'summary_output', 'profile_photo', 'institution_logo');

-- CreateEnum
CREATE TYPE "attempt_status" AS ENUM ('in_progress', 'submitted', 'timed_out', 'flagged', 'graded');

-- CreateEnum
CREATE TYPE "attendance_status" AS ENUM ('present', 'absent', 'late', 'excused', 'manually_overridden');

-- CreateEnum
CREATE TYPE "day_of_week" AS ENUM ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday');

-- CreateEnum
CREATE TYPE "generation_status" AS ENUM ('pending', 'processing', 'completed', 'failed');

-- CreateEnum
CREATE TYPE "notification_channel" AS ENUM ('in_app', 'email', 'push');

-- CreateEnum
CREATE TYPE "notification_type" AS ENUM ('attendance_session_started', 'attendance_warning', 'assignment_published', 'assignment_graded', 'assignment_due_reminder', 'test_scheduled', 'test_starting', 'test_result_released', 'summary_shared', 'general');

-- CreateEnum
CREATE TYPE "plan_tier" AS ENUM ('free', 'basic', 'pro', 'enterprise');

-- CreateEnum
CREATE TYPE "question_type" AS ENUM ('mcq_single', 'mcq_multiple', 'true_false');

-- CreateEnum
CREATE TYPE "semester_type" AS ENUM ('odd', 'even', 'summer');

-- CreateEnum
CREATE TYPE "submission_status" AS ENUM ('submitted', 'late_submitted', 'graded', 'returned', 'resubmission_requested');

-- CreateEnum
CREATE TYPE "subscription_status" AS ENUM ('trialing', 'active', 'past_due', 'cancelled', 'suspended');

-- CreateEnum
CREATE TYPE "test_status" AS ENUM ('draft', 'scheduled', 'active', 'completed', 'cancelled');

-- CreateEnum
CREATE TYPE "user_role" AS ENUM ('super_admin', 'institution_admin', 'hod', 'teacher', 'student');

-- CreateTable
CREATE TABLE "assignments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "subject_enrollment_id" UUID NOT NULL,
    "teacher_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "instructions" TEXT,
    "total_marks" SMALLINT NOT NULL DEFAULT 100,
    "passing_marks" SMALLINT,
    "status" "assignment_status" NOT NULL DEFAULT 'draft',
    "due_at" TIMESTAMPTZ(6) NOT NULL,
    "published_at" TIMESTAMPTZ(6),
    "closed_at" TIMESTAMPTZ(6),
    "allow_late_submission" BOOLEAN NOT NULL DEFAULT false,
    "late_penalty_percent" SMALLINT DEFAULT 0,
    "plagiarism_check_enabled" BOOLEAN NOT NULL DEFAULT true,
    "plagiarism_threshold" SMALLINT NOT NULL DEFAULT 40,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attachments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "uploaded_by" UUID NOT NULL,
    "institution_id" UUID NOT NULL,
    "category" "attachment_category" NOT NULL,
    "original_filename" VARCHAR(255) NOT NULL,
    "stored_filename" VARCHAR(255) NOT NULL,
    "storage_path" TEXT NOT NULL,
    "mime_type" VARCHAR(100) NOT NULL,
    "size_bytes" BIGINT NOT NULL,
    "checksum_sha256" VARCHAR(64),
    "is_public" BOOLEAN NOT NULL DEFAULT false,
    "entity_type" VARCHAR(50),
    "entity_id" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "attachments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attempt_answers" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "attempt_id" UUID NOT NULL,
    "question_id" UUID NOT NULL,
    "selected_option_ids" UUID[],
    "is_correct" BOOLEAN,
    "marks_awarded" DECIMAL(5,2),
    "answered_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attempt_answers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_records" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "session_id" UUID NOT NULL,
    "student_id" UUID NOT NULL,
    "status" "attendance_status" NOT NULL DEFAULT 'absent',
    "marked_at" TIMESTAMPTZ(6),
    "latitude" DECIMAL(10,8),
    "longitude" DECIMAL(11,8),
    "location_accuracy_meters" SMALLINT,
    "wifi_bssid_detected" VARCHAR(50),
    "distance_from_classroom_m" SMALLINT,
    "is_location_valid" BOOLEAN,
    "is_override" BOOLEAN NOT NULL DEFAULT false,
    "override_by" UUID,
    "override_reason" TEXT,
    "override_at" TIMESTAMPTZ(6),
    "device_id" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_records_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_sessions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "subject_enrollment_id" UUID NOT NULL,
    "timetable_slot_id" UUID,
    "teacher_id" UUID NOT NULL,
    "lecture_number" SMALLINT NOT NULL,
    "session_date" DATE NOT NULL,
    "started_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closed_at" TIMESTAMPTZ(6),
    "geofence_latitude" DECIMAL(10,8) NOT NULL,
    "geofence_longitude" DECIMAL(11,8) NOT NULL,
    "geofence_radius_meters" SMALLINT NOT NULL DEFAULT 50,
    "wifi_bssid" VARCHAR(50),
    "total_students" SMALLINT NOT NULL DEFAULT 0,
    "present_count" SMALLINT NOT NULL DEFAULT 0,
    "absent_count" SMALLINT NOT NULL DEFAULT 0,
    "notes" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance_summaries" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "student_id" UUID NOT NULL,
    "subject_enrollment_id" UUID NOT NULL,
    "total_sessions" SMALLINT NOT NULL DEFAULT 0,
    "present_count" SMALLINT NOT NULL DEFAULT 0,
    "absent_count" SMALLINT NOT NULL DEFAULT 0,
    "late_count" SMALLINT NOT NULL DEFAULT 0,
    "excused_count" SMALLINT NOT NULL DEFAULT 0,
    "attendance_percentage" DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    "is_below_threshold" BOOLEAN NOT NULL DEFAULT false,
    "last_updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_summaries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "batches" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "department_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "admission_year" SMALLINT NOT NULL,
    "graduation_year" SMALLINT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "batches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "departments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "institution_id" UUID NOT NULL,
    "hod_id" UUID,
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "institutions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(255) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "phone" VARCHAR(20),
    "address" TEXT,
    "city" VARCHAR(100),
    "state" VARCHAR(100),
    "country" VARCHAR(100) NOT NULL DEFAULT 'India',
    "logo_url" TEXT,
    "website" VARCHAR(255),
    "attendance_threshold" SMALLINT NOT NULL DEFAULT 75,
    "academic_year_start" DATE,
    "academic_year_end" DATE,
    "timezone" VARCHAR(100) NOT NULL DEFAULT 'Asia/Kolkata',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "institutions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "institution_id" UUID NOT NULL,
    "type" "notification_type" NOT NULL,
    "channel" "notification_channel" NOT NULL DEFAULT 'in_app',
    "title" VARCHAR(255) NOT NULL,
    "body" TEXT NOT NULL,
    "action_url" TEXT,
    "entity_type" VARCHAR(50),
    "entity_id" UUID,
    "is_read" BOOLEAN NOT NULL DEFAULT false,
    "read_at" TIMESTAMPTZ(6),
    "is_sent" BOOLEAN NOT NULL DEFAULT false,
    "sent_at" TIMESTAMPTZ(6),
    "failed_at" TIMESTAMPTZ(6),
    "fail_reason" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "question_options" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "question_id" UUID NOT NULL,
    "option_text" TEXT NOT NULL,
    "is_correct" BOOLEAN NOT NULL DEFAULT false,
    "display_order" SMALLINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "question_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "questions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "test_id" UUID NOT NULL,
    "type" "question_type" NOT NULL DEFAULT 'mcq_single',
    "question_text" TEXT NOT NULL,
    "explanation" TEXT,
    "marks" SMALLINT NOT NULL DEFAULT 1,
    "display_order" SMALLINT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "semesters" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "batch_id" UUID NOT NULL,
    "number" SMALLINT NOT NULL,
    "type" "semester_type" NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "is_current" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "semesters_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "student_profiles" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "batch_id" UUID NOT NULL,
    "roll_number" VARCHAR(30) NOT NULL,
    "current_semester_id" UUID,
    "date_of_birth" DATE,
    "guardian_name" VARCHAR(255),
    "guardian_phone" VARCHAR(20),
    "address" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "student_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "student_subject_enrollments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "student_id" UUID NOT NULL,
    "subject_enrollment_id" UUID NOT NULL,
    "enrolled_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "student_subject_enrollments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subject_enrollments" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "subject_id" UUID NOT NULL,
    "semester_id" UUID NOT NULL,
    "teacher_id" UUID NOT NULL,
    "classroom" VARCHAR(50),
    "created_by" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "subject_enrollments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subjects" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "department_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "code" VARCHAR(30) NOT NULL,
    "description" TEXT,
    "credits" SMALLINT,
    "total_lectures_planned" SMALLINT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "subjects_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "submissions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "assignment_id" UUID NOT NULL,
    "student_id" UUID NOT NULL,
    "status" "submission_status" NOT NULL DEFAULT 'submitted',
    "submitted_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_late" BOOLEAN NOT NULL DEFAULT false,
    "student_notes" TEXT,
    "marks_obtained" DECIMAL(6,2),
    "grade_percentage" DECIMAL(5,2),
    "teacher_feedback" TEXT,
    "graded_by" UUID,
    "graded_at" TIMESTAMPTZ(6),
    "ai_suggested_marks" DECIMAL(6,2),
    "ai_suggestion_reasoning" TEXT,
    "plagiarism_score" DECIMAL(5,2),
    "plagiarism_checked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "subscriptions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "institution_id" UUID NOT NULL,
    "plan" "plan_tier" NOT NULL DEFAULT 'free',
    "status" "subscription_status" NOT NULL DEFAULT 'trialing',
    "student_limit" INTEGER NOT NULL DEFAULT 100,
    "storage_limit_gb" SMALLINT NOT NULL DEFAULT 5,
    "trial_ends_at" TIMESTAMPTZ(6),
    "current_period_start" TIMESTAMPTZ(6),
    "current_period_end" TIMESTAMPTZ(6),
    "cancelled_at" TIMESTAMPTZ(6),
    "cancel_reason" TEXT,
    "external_subscription_id" VARCHAR(255),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "subscriptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "summaries" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "subject_enrollment_id" UUID NOT NULL,
    "teacher_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "source_attachment_id" UUID,
    "generation_status" "generation_status" NOT NULL DEFAULT 'pending',
    "generation_model" VARCHAR(100),
    "generation_prompt_version" SMALLINT NOT NULL DEFAULT 1,
    "key_points" JSONB,
    "important_questions" JSONB,
    "full_summary" TEXT,
    "raw_ai_response" TEXT,
    "generation_tokens_used" INTEGER,
    "generation_cost_usd" DECIMAL(8,6),
    "is_shared_with_students" BOOLEAN NOT NULL DEFAULT false,
    "shared_at" TIMESTAMPTZ(6),
    "is_edited_by_teacher" BOOLEAN NOT NULL DEFAULT false,
    "failed_reason" TEXT,
    "retry_count" SMALLINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "summaries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "test_attempts" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "test_id" UUID NOT NULL,
    "student_id" UUID NOT NULL,
    "status" "attempt_status" NOT NULL DEFAULT 'in_progress',
    "started_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "submitted_at" TIMESTAMPTZ(6),
    "time_taken_seconds" INTEGER,
    "marks_obtained" DECIMAL(6,2),
    "percentage" DECIMAL(5,2),
    "is_passed" BOOLEAN,
    "tab_switch_count" SMALLINT NOT NULL DEFAULT 0,
    "is_flagged" BOOLEAN NOT NULL DEFAULT false,
    "flag_reason" TEXT,
    "result_released_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "test_attempts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tests" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "subject_enrollment_id" UUID NOT NULL,
    "teacher_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "instructions" TEXT,
    "status" "test_status" NOT NULL DEFAULT 'draft',
    "scheduled_at" TIMESTAMPTZ(6),
    "duration_minutes" SMALLINT NOT NULL,
    "total_marks" SMALLINT NOT NULL,
    "passing_marks" SMALLINT,
    "randomise_questions" BOOLEAN NOT NULL DEFAULT true,
    "randomise_options" BOOLEAN NOT NULL DEFAULT true,
    "allow_review" BOOLEAN NOT NULL DEFAULT true,
    "show_result_immediately" BOOLEAN NOT NULL DEFAULT false,
    "tab_switch_detection" BOOLEAN NOT NULL DEFAULT true,
    "max_tab_switches_allowed" SMALLINT NOT NULL DEFAULT 3,
    "published_at" TIMESTAMPTZ(6),
    "completed_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "tests_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "timetable_exceptions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "timetable_slot_id" UUID NOT NULL,
    "exception_date" DATE NOT NULL,
    "is_cancelled" BOOLEAN NOT NULL DEFAULT false,
    "replacement_start_time" TIME(6),
    "replacement_end_time" TIME(6),
    "replacement_classroom" VARCHAR(50),
    "reason" TEXT,
    "created_by" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "timetable_exceptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "timetable_slots" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "subject_enrollment_id" UUID NOT NULL,
    "day" "day_of_week" NOT NULL,
    "start_time" TIME(6) NOT NULL,
    "end_time" TIME(6) NOT NULL,
    "classroom" VARCHAR(50),
    "effective_from" DATE NOT NULL,
    "effective_until" DATE,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by" UUID NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "timetable_slots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_sessions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "token_hash" TEXT NOT NULL,
    "device_info" JSONB,
    "last_active_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "revoked_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "institution_id" UUID,
    "role" "user_role" NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "email_verified_at" TIMESTAMPTZ(6),
    "password_hash" TEXT NOT NULL,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "phone" VARCHAR(20),
    "profile_photo_url" TEXT,
    "employee_id" VARCHAR(50),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "is_first_login" BOOLEAN NOT NULL DEFAULT true,
    "last_login_at" TIMESTAMPTZ(6),
    "password_reset_token" TEXT,
    "password_reset_expires_at" TIMESTAMPTZ(6),
    "created_by" UUID,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ(6),

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_users" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" VARCHAR(255) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
    "email_verified" BOOLEAN NOT NULL DEFAULT false,
    "image" TEXT,
    "role" "user_role" NOT NULL DEFAULT 'student',
    "institution_id" UUID,
    "first_login" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_sessions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "token" TEXT NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "ip_address" VARCHAR(100),
    "user_agent" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_accounts" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "account_id" TEXT NOT NULL,
    "provider_id" TEXT NOT NULL,
    "access_token" TEXT,
    "refresh_token" TEXT,
    "access_token_expires_at" TIMESTAMPTZ(6),
    "refresh_token_expires_at" TIMESTAMPTZ(6),
    "scope" TEXT,
    "id_token" TEXT,
    "password" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth_verifications" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "identifier" TEXT NOT NULL,
    "value" TEXT NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth_verifications_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "idx_assignments_due_at" ON "assignments"("due_at");

-- CreateIndex
CREATE INDEX "idx_assignments_status" ON "assignments"("status");

-- CreateIndex
CREATE INDEX "idx_assignments_subject_enrollment_id" ON "assignments"("subject_enrollment_id");

-- CreateIndex
CREATE INDEX "idx_assignments_teacher_id" ON "assignments"("teacher_id");

-- CreateIndex
CREATE INDEX "idx_attachments_entity" ON "attachments"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "idx_attachments_institution_id" ON "attachments"("institution_id");

-- CreateIndex
CREATE INDEX "idx_attachments_uploaded_by" ON "attachments"("uploaded_by");

-- CreateIndex
CREATE INDEX "idx_attempt_answers_attempt_id" ON "attempt_answers"("attempt_id");

-- CreateIndex
CREATE INDEX "idx_attempt_answers_question_id" ON "attempt_answers"("question_id");

-- CreateIndex
CREATE UNIQUE INDEX "attempt_answers_attempt_id_question_id_key" ON "attempt_answers"("attempt_id", "question_id");

-- CreateIndex
CREATE INDEX "idx_attendance_records_marked_at" ON "attendance_records"("marked_at");

-- CreateIndex
CREATE INDEX "idx_attendance_records_session_id" ON "attendance_records"("session_id");

-- CreateIndex
CREATE INDEX "idx_attendance_records_status" ON "attendance_records"("status");

-- CreateIndex
CREATE INDEX "idx_attendance_records_student_id" ON "attendance_records"("student_id");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_records_session_id_student_id_key" ON "attendance_records"("session_id", "student_id");

-- CreateIndex
CREATE INDEX "idx_attendance_sessions_closed_at" ON "attendance_sessions"("closed_at");

-- CreateIndex
CREATE INDEX "idx_attendance_sessions_session_date" ON "attendance_sessions"("session_date");

-- CreateIndex
CREATE INDEX "idx_attendance_sessions_subject_enrollment_id" ON "attendance_sessions"("subject_enrollment_id");

-- CreateIndex
CREATE INDEX "idx_attendance_sessions_teacher_id" ON "attendance_sessions"("teacher_id");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_sessions_subject_enrollment_id_lecture_number_se_key" ON "attendance_sessions"("subject_enrollment_id", "lecture_number", "session_date");

-- CreateIndex
CREATE INDEX "idx_attendance_summaries_is_below_threshold" ON "attendance_summaries"("is_below_threshold");

-- CreateIndex
CREATE INDEX "idx_attendance_summaries_student_id" ON "attendance_summaries"("student_id");

-- CreateIndex
CREATE INDEX "idx_attendance_summaries_subject_enrollment_id" ON "attendance_summaries"("subject_enrollment_id");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_summaries_student_id_subject_enrollment_id_key" ON "attendance_summaries"("student_id", "subject_enrollment_id");

-- CreateIndex
CREATE INDEX "idx_batches_department_id" ON "batches"("department_id");

-- CreateIndex
CREATE INDEX "idx_departments_hod_id" ON "departments"("hod_id");

-- CreateIndex
CREATE INDEX "idx_departments_institution_id" ON "departments"("institution_id");

-- CreateIndex
CREATE UNIQUE INDEX "departments_institution_id_code_key" ON "departments"("institution_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "institutions_slug_key" ON "institutions"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "institutions_email_key" ON "institutions"("email");

-- CreateIndex
CREATE INDEX "idx_institutions_deleted_at" ON "institutions"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_institutions_is_active" ON "institutions"("is_active");

-- CreateIndex
CREATE INDEX "idx_institutions_slug" ON "institutions"("slug");

-- CreateIndex
CREATE INDEX "idx_notifications_created_at" ON "notifications"("created_at");

-- CreateIndex
CREATE INDEX "idx_notifications_entity" ON "notifications"("entity_type", "entity_id");

-- CreateIndex
CREATE INDEX "idx_notifications_is_read" ON "notifications"("is_read");

-- CreateIndex
CREATE INDEX "idx_notifications_user_id" ON "notifications"("user_id");

-- CreateIndex
CREATE INDEX "idx_question_options_question_id" ON "question_options"("question_id");

-- CreateIndex
CREATE INDEX "idx_questions_test_id" ON "questions"("test_id");

-- CreateIndex
CREATE INDEX "idx_semesters_batch_id" ON "semesters"("batch_id");

-- CreateIndex
CREATE INDEX "idx_semesters_is_current" ON "semesters"("is_current");

-- CreateIndex
CREATE UNIQUE INDEX "semesters_batch_id_number_key" ON "semesters"("batch_id", "number");

-- CreateIndex
CREATE UNIQUE INDEX "student_profiles_user_id_key" ON "student_profiles"("user_id");

-- CreateIndex
CREATE INDEX "idx_student_profiles_batch_id" ON "student_profiles"("batch_id");

-- CreateIndex
CREATE INDEX "idx_student_profiles_roll_number" ON "student_profiles"("roll_number");

-- CreateIndex
CREATE INDEX "idx_student_profiles_user_id" ON "student_profiles"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "student_profiles_batch_id_roll_number_key" ON "student_profiles"("batch_id", "roll_number");

-- CreateIndex
CREATE INDEX "idx_sse_student_id" ON "student_subject_enrollments"("student_id");

-- CreateIndex
CREATE INDEX "idx_sse_subject_enrollment_id" ON "student_subject_enrollments"("subject_enrollment_id");

-- CreateIndex
CREATE UNIQUE INDEX "student_subject_enrollments_student_id_subject_enrollment_i_key" ON "student_subject_enrollments"("student_id", "subject_enrollment_id");

-- CreateIndex
CREATE INDEX "idx_subject_enrollments_semester_id" ON "subject_enrollments"("semester_id");

-- CreateIndex
CREATE INDEX "idx_subject_enrollments_subject_id" ON "subject_enrollments"("subject_id");

-- CreateIndex
CREATE INDEX "idx_subject_enrollments_teacher_id" ON "subject_enrollments"("teacher_id");

-- CreateIndex
CREATE UNIQUE INDEX "subject_enrollments_subject_id_semester_id_key" ON "subject_enrollments"("subject_id", "semester_id");

-- CreateIndex
CREATE INDEX "idx_subjects_department_id" ON "subjects"("department_id");

-- CreateIndex
CREATE UNIQUE INDEX "subjects_department_id_code_key" ON "subjects"("department_id", "code");

-- CreateIndex
CREATE INDEX "idx_submissions_assignment_id" ON "submissions"("assignment_id");

-- CreateIndex
CREATE INDEX "idx_submissions_graded_by" ON "submissions"("graded_by");

-- CreateIndex
CREATE INDEX "idx_submissions_status" ON "submissions"("status");

-- CreateIndex
CREATE INDEX "idx_submissions_student_id" ON "submissions"("student_id");

-- CreateIndex
CREATE UNIQUE INDEX "submissions_assignment_id_student_id_key" ON "submissions"("assignment_id", "student_id");

-- CreateIndex
CREATE INDEX "idx_subscriptions_institution_id" ON "subscriptions"("institution_id");

-- CreateIndex
CREATE INDEX "idx_subscriptions_status" ON "subscriptions"("status");

-- CreateIndex
CREATE INDEX "idx_summaries_generation_status" ON "summaries"("generation_status");

-- CreateIndex
CREATE INDEX "idx_summaries_is_shared" ON "summaries"("is_shared_with_students");

-- CreateIndex
CREATE INDEX "idx_summaries_subject_enrollment_id" ON "summaries"("subject_enrollment_id");

-- CreateIndex
CREATE INDEX "idx_summaries_teacher_id" ON "summaries"("teacher_id");

-- CreateIndex
CREATE INDEX "idx_test_attempts_status" ON "test_attempts"("status");

-- CreateIndex
CREATE INDEX "idx_test_attempts_student_id" ON "test_attempts"("student_id");

-- CreateIndex
CREATE INDEX "idx_test_attempts_test_id" ON "test_attempts"("test_id");

-- CreateIndex
CREATE UNIQUE INDEX "test_attempts_test_id_student_id_key" ON "test_attempts"("test_id", "student_id");

-- CreateIndex
CREATE INDEX "idx_tests_scheduled_at" ON "tests"("scheduled_at");

-- CreateIndex
CREATE INDEX "idx_tests_status" ON "tests"("status");

-- CreateIndex
CREATE INDEX "idx_tests_subject_enrollment_id" ON "tests"("subject_enrollment_id");

-- CreateIndex
CREATE INDEX "idx_tests_teacher_id" ON "tests"("teacher_id");

-- CreateIndex
CREATE INDEX "idx_timetable_exceptions_date" ON "timetable_exceptions"("exception_date");

-- CreateIndex
CREATE INDEX "idx_timetable_exceptions_slot_id" ON "timetable_exceptions"("timetable_slot_id");

-- CreateIndex
CREATE INDEX "idx_timetable_slots_day" ON "timetable_slots"("day");

-- CreateIndex
CREATE INDEX "idx_timetable_slots_subject_enrollment_id" ON "timetable_slots"("subject_enrollment_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_sessions_token_hash_key" ON "user_sessions"("token_hash");

-- CreateIndex
CREATE INDEX "idx_user_sessions_expires_at" ON "user_sessions"("expires_at");

-- CreateIndex
CREATE INDEX "idx_user_sessions_token_hash" ON "user_sessions"("token_hash");

-- CreateIndex
CREATE INDEX "idx_user_sessions_user_id" ON "user_sessions"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "idx_users_deleted_at" ON "users"("deleted_at");

-- CreateIndex
CREATE INDEX "idx_users_email" ON "users"("email");

-- CreateIndex
CREATE INDEX "idx_users_institution_id" ON "users"("institution_id");

-- CreateIndex
CREATE INDEX "idx_users_is_active" ON "users"("is_active");

-- CreateIndex
CREATE INDEX "idx_users_role" ON "users"("role");

-- CreateIndex
CREATE UNIQUE INDEX "auth_users_email_key" ON "auth_users"("email");

-- CreateIndex
CREATE INDEX "idx_auth_users_institution_id" ON "auth_users"("institution_id");

-- CreateIndex
CREATE UNIQUE INDEX "auth_sessions_token_key" ON "auth_sessions"("token");

-- CreateIndex
CREATE INDEX "idx_auth_sessions_expires_at" ON "auth_sessions"("expires_at");

-- CreateIndex
CREATE INDEX "idx_auth_sessions_user_id" ON "auth_sessions"("user_id");

-- CreateIndex
CREATE INDEX "idx_auth_accounts_provider_id" ON "auth_accounts"("provider_id");

-- CreateIndex
CREATE INDEX "idx_auth_accounts_user_id" ON "auth_accounts"("user_id");

-- CreateIndex
CREATE INDEX "idx_auth_verifications_expires_at" ON "auth_verifications"("expires_at");

-- CreateIndex
CREATE INDEX "idx_auth_verifications_identifier" ON "auth_verifications"("identifier");

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_subject_enrollment_id_fkey" FOREIGN KEY ("subject_enrollment_id") REFERENCES "subject_enrollments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "assignments" ADD CONSTRAINT "assignments_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attachments" ADD CONSTRAINT "attachments_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attachments" ADD CONSTRAINT "attachments_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attempt_answers" ADD CONSTRAINT "attempt_answers_attempt_id_fkey" FOREIGN KEY ("attempt_id") REFERENCES "test_attempts"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attempt_answers" ADD CONSTRAINT "attempt_answers_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_override_by_fkey" FOREIGN KEY ("override_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "attendance_sessions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attendance_records" ADD CONSTRAINT "attendance_records_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attendance_sessions" ADD CONSTRAINT "attendance_sessions_subject_enrollment_id_fkey" FOREIGN KEY ("subject_enrollment_id") REFERENCES "subject_enrollments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attendance_sessions" ADD CONSTRAINT "attendance_sessions_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attendance_sessions" ADD CONSTRAINT "attendance_sessions_timetable_slot_id_fkey" FOREIGN KEY ("timetable_slot_id") REFERENCES "timetable_slots"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attendance_summaries" ADD CONSTRAINT "attendance_summaries_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "attendance_summaries" ADD CONSTRAINT "attendance_summaries_subject_enrollment_id_fkey" FOREIGN KEY ("subject_enrollment_id") REFERENCES "subject_enrollments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "batches" ADD CONSTRAINT "batches_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "batches" ADD CONSTRAINT "batches_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_hod_id_fkey" FOREIGN KEY ("hod_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "question_options" ADD CONSTRAINT "question_options_question_id_fkey" FOREIGN KEY ("question_id") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_test_id_fkey" FOREIGN KEY ("test_id") REFERENCES "tests"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "semesters" ADD CONSTRAINT "semesters_batch_id_fkey" FOREIGN KEY ("batch_id") REFERENCES "batches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "student_profiles" ADD CONSTRAINT "student_profiles_batch_id_fkey" FOREIGN KEY ("batch_id") REFERENCES "batches"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "student_profiles" ADD CONSTRAINT "student_profiles_current_semester_id_fkey" FOREIGN KEY ("current_semester_id") REFERENCES "semesters"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "student_profiles" ADD CONSTRAINT "student_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "student_subject_enrollments" ADD CONSTRAINT "student_subject_enrollments_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "student_subject_enrollments" ADD CONSTRAINT "student_subject_enrollments_subject_enrollment_id_fkey" FOREIGN KEY ("subject_enrollment_id") REFERENCES "subject_enrollments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "subject_enrollments" ADD CONSTRAINT "subject_enrollments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "subject_enrollments" ADD CONSTRAINT "subject_enrollments_semester_id_fkey" FOREIGN KEY ("semester_id") REFERENCES "semesters"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "subject_enrollments" ADD CONSTRAINT "subject_enrollments_subject_id_fkey" FOREIGN KEY ("subject_id") REFERENCES "subjects"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "subject_enrollments" ADD CONSTRAINT "subject_enrollments_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "subjects" ADD CONSTRAINT "subjects_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "subjects" ADD CONSTRAINT "subjects_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "submissions" ADD CONSTRAINT "submissions_assignment_id_fkey" FOREIGN KEY ("assignment_id") REFERENCES "assignments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "submissions" ADD CONSTRAINT "submissions_graded_by_fkey" FOREIGN KEY ("graded_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "submissions" ADD CONSTRAINT "submissions_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "subscriptions" ADD CONSTRAINT "subscriptions_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "summaries" ADD CONSTRAINT "summaries_source_attachment_id_fkey" FOREIGN KEY ("source_attachment_id") REFERENCES "attachments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "summaries" ADD CONSTRAINT "summaries_subject_enrollment_id_fkey" FOREIGN KEY ("subject_enrollment_id") REFERENCES "subject_enrollments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "summaries" ADD CONSTRAINT "summaries_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "test_attempts" ADD CONSTRAINT "test_attempts_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "test_attempts" ADD CONSTRAINT "test_attempts_test_id_fkey" FOREIGN KEY ("test_id") REFERENCES "tests"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tests" ADD CONSTRAINT "tests_subject_enrollment_id_fkey" FOREIGN KEY ("subject_enrollment_id") REFERENCES "subject_enrollments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tests" ADD CONSTRAINT "tests_teacher_id_fkey" FOREIGN KEY ("teacher_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "timetable_exceptions" ADD CONSTRAINT "timetable_exceptions_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "timetable_exceptions" ADD CONSTRAINT "timetable_exceptions_timetable_slot_id_fkey" FOREIGN KEY ("timetable_slot_id") REFERENCES "timetable_slots"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "timetable_slots" ADD CONSTRAINT "timetable_slots_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "timetable_slots" ADD CONSTRAINT "timetable_slots_subject_enrollment_id_fkey" FOREIGN KEY ("subject_enrollment_id") REFERENCES "subject_enrollments"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "user_sessions" ADD CONSTRAINT "user_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_institution_id_fkey" FOREIGN KEY ("institution_id") REFERENCES "institutions"("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "auth_sessions" ADD CONSTRAINT "auth_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth_users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "auth_accounts" ADD CONSTRAINT "auth_accounts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth_users"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
