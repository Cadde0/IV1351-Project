/* Query 1 */

SELECT 
    TO_CHAR(activity.start_time, 'Mon') AS month,
    COUNT(DISTINCT activity.activity_id) AS total,
    COUNT(DISTINCT lesson_individual.activity_id) AS individual,
    COUNT(DISTINCT lesson_group.activity_id) AS group,
    COUNT(DISTINCT ensamble.activity_id) AS ensamble
FROM 
    activity
LEFT JOIN 
    lesson_individual ON activity.activity_id = lesson_individual.activity_id   
LEFT JOIN 
    lesson_group ON activity.activity_id = lesson_group.activity_id
LEFT JOIN 
    ensamble ON activity.activity_id = ensamble.activity_id
WHERE
    EXTRACT(YEAR FROM activity.start_time) = 2024
GROUP BY
    TO_CHAR(activity.start_time, 'Mon'), EXTRACT(MONTH FROM activity.start_time)
ORDER BY 
    EXTRACT(MONTH FROM activity.start_time);


/* Query 2 */

-- Count the number of siblings for each student
WITH sibling_count AS ( 
SELECT 
    student_school_id_first AS student_id,
    COUNT(student_school_id_second) AS no_of_siblings
FROM sibling
GROUP BY student_school_id_first
UNION ALL
SELECT 
    student_school_id_second AS student_id,
    COUNT(student_school_id_first) AS no_of_siblings
FROM sibling
GROUP BY student_school_id_second
),
-- Aggregate sibling count for each student
total_sibling_count AS (
SELECT 
    student_id,
    SUM(no_of_siblings) AS no_of_siblings_sum
FROM sibling_count
GROUP BY student_id
)
-- Count students by their sibling count
SELECT
    COALESCE(no_of_siblings_sum,0) AS "No of Siblings",
    COUNT(*) AS "No of Students"
FROM student
LEFT JOIN
    total_sibling_count ON student.student_school_id = total_sibling_count.student_id
GROUP BY
    "No of Siblings"
ORDER BY "No of Siblings";


/* Query 3 */

WITH lessons_this_month AS (
    SELECT 
        instructor_school_id, 
        COUNT(*) AS total_lessons
    FROM activity
    WHERE 
        EXTRACT(MONTH FROM start_time) = EXTRACT(MONTH FROM CURRENT_DATE)
        AND EXTRACT(YEAR FROM start_time) = EXTRACT(YEAR FROM CURRENT_DATE)
    GROUP BY instructor_school_id
)
SELECT 
    person.school_id AS "Instructor Id", 
    person.first_name AS "First Name",
    person.last_name AS "Last Name", 
    total_lessons AS "No of Lessons"
FROM lessons_this_month
JOIN person ON lessons_this_month.instructor_school_id = person.school_id
WHERE lessons_this_month.total_lessons > 0 -- number of given lessons
ORDER BY "No of Lessons" DESC;


/* Query 4 */

WITH ensambles_next_week AS (
  SELECT activity.activity_id,
    ensamble.genre,
    ensamble.max_students,
    activity.start_time
  from activity,
    ensamble
  WHERE start_time >= DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '7 days'
    AND start_time < DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '14 days'
    AND activity.activity_id = ensamble.activity_id
),
bookings_per_ensamble AS (
  SELECT booking.activity_id,
    COUNT(booking.student_school_id) as booked_students
  FROM ensambles_next_week
    LEFT JOIN booking ON ensambles_next_week.activity_id = booking.activity_id
  GROUP BY booking.activity_id
)
SELECT TO_CHAR(start_time, 'Dy') as "Day",
  genre as "Genre",
  CASE
    WHEN max_students - COALESCE(booked_students, 0) <= 0 THEN 'No seats'
    WHEN max_students - COALESCE(booked_students, 0) <= 2 THEN '1 or 2 seats'
    ELSE 'Many seats'
  END AS "No of Free Seats"
FROM ensambles_next_week
  LEFT JOIN bookings_per_ensamble on ensambles_next_week.activity_id = bookings_per_ensamble.activity_id