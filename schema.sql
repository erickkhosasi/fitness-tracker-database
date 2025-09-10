-- Represent users of the app
CREATE TABLE IF NOT EXISTS "users" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT,
    "username" TEXT NOT NULL UNIQUE,
    "gender" TEXT CHECK("gender" IN ('Male', 'Female') OR "gender" IS NULL),
    "birth_date" NUMERIC,
    "height_cm" REAL,
    "weight_kg" REAL,
    PRIMARY KEY("id")
);

-- Master lists of available exercises
CREATE TABLE IF NOT EXISTS "exercises" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "description" TEXT NOT NULL,
    "muscle_group" TEXT NOT NULL,
    "type" TEXT NOT NULL CHECK("type" IN ('Compound', 'Isolation')),
    PRIMARY KEY("id")
);

-- Master lists of foods and their nutritional value
CREATE TABLE IF NOT EXISTS "foods" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "calories" REAL NOT NULL,
    "carbs_g" REAL NOT NULL,
    "protein_g" REAL NOT NULL,
    "fat_g" REAL NOT NULL,
    "serving_size_g" REAL NOT NULL, -- serving size of the food for the stated nutriotional value
    PRIMARY KEY("id")
);

-- Logs each workout session performed by users
CREATE TABLE IF NOT EXISTS "workouts" (
    "id" INTEGER,
    "user_id" INTEGER,
    "date" NUMERIC NOT NULL DEFAULT CURRENT_DATE,
    "duration_h" REAL NOT NULL,
    "notes" TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
);

-- Represent detailed breakdown of exercises per workout session
CREATE TABLE IF NOT EXISTS "workout_details" (
    "id" INTEGER,
    "workout_id" INTEGER,
    "exercise_id" INTEGER,
    "sets" INTEGER NOT NULL,
    "reps" INTEGER NOT NULL,
    "weight_kg" REAL NOT NULL,
    PRIMARY KEY("id"),
    FOREIGN KEY("workout_id") REFERENCES "workouts"("id"),
    FOREIGN KEY("exercise_id") REFERENCES "exercises"("id")
    UNIQUE("workout_id", "exercise_id", "weight_kg")
);

-- Logs what a user eat for each meal
CREATE TABLE IF NOT EXISTS "meals" (
    "id" INTEGER,
    "user_id" INTEGER,
    "date" NUMERIC NOT NULL DEFAULT CURRENT_DATE,
    "food_id" INTEGER,
    "serving_size_g" REAL NOT NULL, -- serving size of the food eaten by user
    "meal_type" TEXT NOT NULL CHECK("meal_type" IN ('Breakfast', 'Lunch', 'Dinner', 'Snack')),
    "notes" TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("food_id") REFERENCES "foods"("id"),
    UNIQUE("user_id", "date", "meal_type", "food_id")
);

-- Logs user physical progress over time
CREATE TABLE IF NOT EXISTS "progress" (
    "id" INTEGER,
    "user_id" INTEGER,
    "date" NUMERIC NOT NULL DEFAULT CURRENT_DATE,
    "weight_kg" REAL NOT NULL,
    "body_fat" REAL NOT NULL,
    "muscle_mass" REAL NOT NULL,
    "notes" TEXT,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
    UNIQUE("user_id", "date")
);

-- Create view to join table between users, workout session, workout details, and exercises
CREATE VIEW "workout_list" AS
SELECT "workout_details"."id",
       "exercises"."name" AS "exercise",
       "muscle_group",
       "username",
       "date",
       "sets",
       "reps",
       "workout_details"."weight_kg" AS "weight_kg"
FROM "workout_details"
JOIN "exercises" ON "workout_details"."exercise_id" = "exercises"."id"
JOIN "workouts" ON "workout_details"."workout_id" = "workouts"."id"
JOIN "users" ON "workouts"."user_id" = "users"."id";

-- Create view to calculate nutrients for each meal
CREATE VIEW "meal_nutrients" AS
SELECT
    "meals"."id" AS "id",
    "username",
    "date",
    "meal_type",
    "name",
    "meals"."serving_size_g" AS "serving_size (g)",
    "meals"."serving_size_g" / "foods"."serving_size_g" * "calories" AS "calories",
    "meals"."serving_size_g" / "foods"."serving_size_g" * "carbs_g" AS "carbs (g)",
    "meals"."serving_size_g" / "foods"."serving_size_g" * "protein_g" AS "protein (g)",
    "meals"."serving_size_g" / "foods"."serving_size_g" * "fat_g" AS "fat (g)"
FROM "meals"
JOIN "users" ON "meals"."user_id" = "users"."id"
JOIN "foods" ON "meals"."food_id" = "foods"."id";

-- Craete view to join user and progress table
CREATE VIEW "user_progress" AS
SELECT
    "progress"."id" AS "id",
    "username",
    "date",
    "progress"."weight_kg",
    "body_fat",
    "muscle_mass"
FROM "progress"
JOIN "users" ON "progress"."user_id" = "users"."id";

-- Create indexes to optimize common queries
CREATE INDEX "idx_username_search" ON "users"("username");
CREATE INDEX "idx_workouts_users_id" ON "workouts"("user_id");
CREATE INDEX "idx_meals_user_id" ON "meals"("user_id");
CREATE INDEX "idx_progress_user_id" ON "progress"("user_id");
CREATE INDEX "idx_workouts_date" ON "workouts"("date");
CREATE INDEX "idx_workout_details_session_id" ON "workout_details"("workout_id");
