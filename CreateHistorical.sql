CREATE TYPE activity_type_enum AS ENUM ('Private Lesson', 'Group Lesson', 'Ensemble');

CREATE TABLE activity_history (
    activity_id INT NOT NULL,
    student_school_id INT NOT NULL,
    activity_date TIMESTAMP(6) NOT NULL,
    activity_type activity_type_enum NOT NULL,
    activity_price DECIMAL(10, 2) NOT NULL,
    genre VARCHAR(99),
    instrument VARCHAR(25),
    student_firstname VARCHAR(50) NOT NULL,
    student_lastname VARCHAR(50) NOT NULL,
    student_email VARCHAR(254),
    CONSTRAINT activity_history_PK PRIMARY KEY (student_school_id, activity_id),
    CHECK (activity_price >= 0),
    CHECK (activity_type != 'Ensemble' OR (genre IS NOT NULL AND instrument IS NULL)),
    CHECK (activity_type = 'Ensemble' OR (genre IS NULL AND instrument IS NOT NULL))
);

/* See queries.sql for query on how to import historical data */