-- Add a new user
INSERT INTO "users" ("first_name", "last_name", "username", "gender", "birth_date", "height_cm", "weight_kg")
VALUES ('Erick', 'Khosasi', 'erickkhosasi', 'Male', '1998-01-01', 170, 75);

-- Add a new exercise into masterlist
INSERT INTO "exercises" ("name", "description", "muscle_group", "type")
VALUES ('Squat', 'description', 'Legs', 'Compound'),
('Deadlift', 'description', 'Back', 'Compound'),
('Bicep Curl', 'description', 'Arms', 'Isolation'),
('Shoulder Press', 'description', 'Shoulders', 'Compound'),
('Bench Press', 'description', 'Chest', 'Compound');

-- Add a new food into masterlist
INSERT INTO "foods" ("name", "calories", "carbs_g", "protein_g", "fat_g", "serving_size_g")
VALUES ('Chicken Breast', 165, 0, 31, 3.6, 100),
('Brown Rice', 111, 23, 2.6, 0.9, 100),
('Broccoli', 55, 11.1, 3.7, 0.3, 100),
('Peanut Butter', 588, 20, 25, 50, 100),
('Banana', 89, 22.8, 1.1, 0.3, 100);

-- Add a new workout session
INSERT INTO "workouts" ("user_id", "date", "duration_h")
VALUES (1, '2025-05-19', 1.0),
(1, '2025-05-20', 1.5),
(1, '2025-05-21', 0.75);

-- Add a new workout details
INSERT INTO "workout_details" ("workout_id", "exercise_id", "sets", "reps", "weight_kg")
VALUES (1, 1, 4, 10, 100),  -- Squat
(1, 2, 4, 10, 120),         -- Deadlift
(2, 5, 4, 10, 80),          -- Bench Press
(2, 4, 4, 10, 40),          -- Shoulder Press
(3, 3, 4, 12, 25);          -- Bicep Curl

-- Add a new meals
INSERT INTO "meals" ("user_id", "date", "food_id", "meal_type", "serving_size_g")
VALUES (1, '2025-05-19', 2, 'Dinner', 200),
(1, '2025-05-19', 3, 'Dinner', 100),
(1, '2025-05-19', 4, 'Snack', 100),
(1, '2025-05-19', 5, 'Snack', 100),
(1, '2025-05-20', 1, 'Breakfast', 150),
(1, '2025-05-20', 5, 'Breakfast', 100),
(1, '2025-05-20', 4, 'Snack', 30),
(1, '2025-05-20', 5, 'Snack', 70),
(1, '2025-05-19', 1, 'Lunch', 100),
(1, '2025-05-19', 2, 'Lunch', 150),
(1, '2025-05-19', 3, 'Lunch', 100),

-- Add a new physical progress log
INSERT INTO "progress" ("user_id", "date", "weight_kg", "body_fat", "muscle_mass")
VALUES (1, '2025-05-19', 75.0, 22.0, 36.5),
(1, '2025-05-20', 74.5, 21.0, 37.5),
(1, '2025-05-21', 74.2, 20.0, 39.0);

-- Find the all-time total workouts session and durations performed by user
SELECT
    COUNT("workouts"."id") AS "total_sessions",
    SUM("duration_h") AS "total_duration",
    MIN("date") AS "start_date"
FROM "workouts"
JOIN "users" ON "workouts"."user_id" = "users"."id"
WHERE "username" = 'erickkhosasi';

-- Find the total workouts session and durations based on day
SELECT
    "date", COUNT("workouts"."id") AS "total_sessions",
    SUM("duration_h") AS "total_duration"
FROM "workouts"
JOIN "users" ON "workouts"."user_id" = "users"."id"
WHERE "username" = 'erickkhosasi'
GROUP BY "date";

-- Find the total workouts session and durations based on month
SELECT
    STRFTIME('%m-%Y', "date") AS "month",
    COUNT("workouts"."id") AS "total_sessions",
    SUM("duration_h") AS "total_duration"
FROM "workouts"
JOIN "users" ON "workouts"."user_id" = "users"."id"
WHERE "username" = 'erickkhosasi'
GROUP BY "month";

-- Find the total workouts session and durations based on year
SELECT
    STRFTIME('%Y', "date") AS "year",
    COUNT("workouts"."id") AS "total_sessions",
    SUM("duration_h") AS "total_duration"
FROM "workouts"
JOIN "users" ON "workouts"."user_id" = "users"."id"
WHERE "username" = 'erickkhosasi'
GROUP BY "year";

-- Find the all-time total weight volume moved by users
SELECT
    SUM("sets" * "reps" * "weight_kg") AS "total_weight_moved (kg)",
    MIN("date") AS "start_date"
FROM "workout_list"
WHERE "username" = 'erickkhosasi';

-- Find the all-time total weight volume moved by users grouped by exercise
SELECT
    "exercise",
    SUM("sets") AS "total_set",
    SUM("sets" * "reps") AS "total_reps",
    SUM("sets" * "reps" * "weight_kg") AS "total_weight_moved (kg)",
    MIN("date") AS "start_date"
FROM "workout_list"
WHERE "username" = 'erickkhosasi'
GROUP BY "exercise"
ORDER BY "total_weight_moved (kg)" DESC;

-- Find the total weight volume moved by users grouped by exercise and date/month/year
SELECT
    STRFTIME('%m-%Y', "date") AS "month",
    "exercise",
    SUM("sets") AS "total_set",
    SUM("sets" * "reps") AS "total_reps",
    SUM("sets" * "reps" * "weight_kg") AS "total_weight_moved (kg)"
FROM "workout_list"
WHERE "username" = 'erickkhosasi'
GROUP BY "month", "exercise"
ORDER BY "total_weight_moved (kg)" DESC;

-- Find the app's top 3 favorite exercises based on total reps, grouped by muscle group
WITH "ranked_exercises" AS (
    SELECT
        "muscle_group",
        "exercise",
        SUM("sets" * "reps") AS "total_reps",
        DENSE_RANK() OVER (
            PARTITION BY "muscle_group"
            ORDER BY SUM("sets" * "reps") DESC
        ) AS "exercise_rank"
    FROM "workout_list"
    GROUP BY "muscle_group", "exercise"
)
SELECT "muscle_group", "exercise", "total_reps"
FROM "ranked_exercises"
WHERE "exercise_rank" <= 3;

-- Find the PR (Personal Record) weight for each exercise
WITH "user_pr" AS (
    SELECT
        "muscle_group",
        "exercise",
        "weight_kg" AS "pr_weight (kg)",
        "date",
        "username",
        DENSE_RANK() OVER (
            PARTITION BY "exercise"
            ORDER BY "weight_kg" DESC
        ) AS "user_rank"
    FROM "workout_list"
)
SELECT "muscle_group", "exercise", "pr_weight (kg)", "date", "username"
FROM "user_pr"
WHERE "user_rank" = 1;

-- Find the total macronutrients consumed by user for each meal
SELECT
    "date",
    "meal_type",
    SUM("calories") AS "calories",
    SUM("carbs (g)") AS "carbs (g)",
    SUM("protein (g)") AS "protein (g)",
    SUM("fat (g)") AS "fat (g)"
FROM "meal_nutrients"
WHERE "username" = 'erickkhosasi'
GROUP BY "date", "meal_type"
ORDER BY "date", CASE
    WHEN "meal_type" = 'Breakfast' THEN 1
    WHEN "meal_type" = 'Lunch' THEN 2
    WHEN "meal_type" = 'Dinner' THEN 3
    WHEN "meal_type" = 'Snack' THEN 4
    END
;

-- Find total macronutrients consumed by user per day
SELECT
    "date",
    SUM("calories") AS "calories",
    SUM("carbs (g)") AS "carbs (g)",
    SUM("protein (g)") AS "protein (g)",
    SUM("fat (g)") AS "fat (g)"
FROM "meal_nutrients"
WHERE "username" = 'erickkhosasi'
GROUP BY "date"
ORDER BY "date";

-- Track user's physical progress
SELECT
    "date",
    "weight_kg",
    "body_fat",
    "muscle_mass"
From "user_progress"
WHERE "username" = 'erickkhosasi'
ORDER BY "date";

-- Summarize user's physical progress insight per month
SELECT
    STRFTIME('%m-%Y', "date") AS "month",
    MIN("weight_kg") AS "min_weight (kg)",
    MAX("weight_kg") AS "max_weight (kg)",
    ROUND(AVG("weight_kg"), 1) AS "avg_weight (kg)",
    MIN("body_fat") AS "min_body_fat",
    MAX("body_fat") AS "max_body_fat",
    ROUND(AVG("body_fat"), 1) AS "avg_body_fat",
    MIN("muscle_mass") AS "min_muscle_mass",
    MAX("muscle_mass") AS "max_muscle_mass",
    ROUND(AVG("muscle_mass"), 1) AS "avg_muscle_mass"
FROM "user_progress"
WHERE "username" = 'erickkhosasi'
GROUP BY "month"
ORDER BY "month";
