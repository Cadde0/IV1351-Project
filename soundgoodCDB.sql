CREATE TABLE person (
    school_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    personal_id_number CHAR(13) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    address VARCHAR(100),
    zip_code CHAR(6),
    city VARCHAR(100)
);

ALTER TABLE person ADD CONSTRAINT person_PK PRIMARY KEY (school_id);
ALTER TABLE person ADD CONSTRAINT unique_personal_number UNIQUE (personal_id_number);

/**/

CREATE TABLE contact_details (
    contact_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    school_id INT NOT NULL REFERENCES person (school_id),
    is_personal BOOLEAN NOT NULL,  
    belongs_to VARCHAR(50),
    phone_number VARCHAR(15),
    email VARCHAR(320)
);

ALTER TABLE contact_details ADD CONSTRAINT contact_details_PK PRIMARY KEY (contact_id, school_id);
/*ALTER TABLE contact_details ADD CONSTRAINT contact_types CHECK (contact_type = 'personal', )*/

CREATE TABLE student (
    school_id INT NOT NULL REFERENCES person (school_id),
    sibling_id INT
);

ALTER TABLE student ADD CONSTRAINT student_PK PRIMARY KEY (school_id);

CREATE TABLE instructor (
    school_id INT NOT NULL REFERENCES person (school_id),
    can_teach_ensamble BOOLEAN
);

ALTER TABLE instructor ADD CONSTRAINT instructor_PK PRIMARY KEY (school_id);

CREATE TABLE instrument_skill (
    instrument_type VARCHAR(100) NOT NULL,
    instructor_school_id INT NOT NULL REFERENCES instructor (school_id),
    skill_level INT NOT NULL
);

ALTER TABLE instrument_skill ADD CONSTRAINT instrument_skill_PK PRIMARY KEY (instrument_type, instructor_school_id);

CREATE TABLE instrument (
    inventory_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    instrument_type VARCHAR(100) NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(100),
    quantity INT NOT NULL,
    rental_cost MONEY NOT NULL
);

ALTER TABLE instrument ADD CONSTRAINT instrument_PK PRIMARY KEY (inventory_id);

CREATE TABLE rental (
    rental_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    is_paid_for BOOLEAN NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    school_id INT NOT NULL REFERENCES person (school_id),
    inventory_id INT NOT NULL REFERENCES instrument (inventory_id)
);

ALTER TABLE rental ADD CONSTRAINT rental_PK PRIMARY KEY (rental_id);

CREATE TABLE location (
    location_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    room_name VARCHAR(25),
    video_link VARCHAR(999)
);

ALTER TABLE location ADD CONSTRAINT location_PK PRIMARY KEY (location_id);

CREATE TABLE pricing (
    price_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    active BOOLEAN NOT NULL,
    skill_level INT NOT NULL,
    activity_type INT NOT NULL,
    price MONEY NOT NULL,
    sibling_discount DECIMAL(5,2)
);
/* Skill level constraint 1-3*/
/* activity type index? 1-3? constraint?*/
ALTER TABLE pricing ADD CONSTRAINT pricing_PK PRIMARY KEY (price_id);

CREATE TABLE activity (
    activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    instructor_school_id INT NOT NULL REFERENCES instructor (school_id),
    location_id INT NOT NULL REFERENCES location (location_id),
    price_id INT NOT NULL REFERENCES pricing (price_id),
    start_time TIMESTAMP(6) NOT NULL,
    end_time TIMESTAMP(6) NOT NULL,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NOT NULL
);

ALTER TABLE activity ADD CONSTRAINT activity_PK PRIMARY KEY (activity_id);

CREATE TABLE booking (
    student_school_id INT NOT NULL REFERENCES student (school_id),
    activity_id INT NOT NULL REFERENCES activity (activity_id),
    is_paid_for BOOLEAN
);

ALTER TABLE booking ADD CONSTRAINT booking_PK PRIMARY KEY (student_school_id, activity_id);

CREATE TABLE lesson (
    activity_id INT NOT NULL REFERENCES activity (activity_id),
    instrument_type VARCHAR(100) NOT NULL,
    skill_level INT NOT NULL,
    min_students INT,
    max_students INT
);

ALTER TABLE lesson ADD CONSTRAINT lesson_PK PRIMARY KEY (activity_id);

/* Skill level constraint 1-3?*/

CREATE TABLE ensamble (
    activity_id INT NOT NULL REFERENCES activity (activity_id),
    genre VARCHAR(99) NOT NULL,
    min_students INT NOT NULL,
    max_students INT NOT NULL
);

ALTER TABLE ensamble ADD CONSTRAINT ensamble_PK PRIMARY KEY (activity_id);
