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


    