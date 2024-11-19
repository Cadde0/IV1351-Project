CREATE TABLE person (
    school_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    personal_id_number CHAR(13) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    address VARCHAR(100),
    zip_code CHAR(5),
    city VARCHAR(100),
    CONSTRAINT person_PK PRIMARY KEY (school_id),
    CONSTRAINT unique_personal_number UNIQUE (personal_id_number),
    CHECK (personal_id_number ~ '^[0-9]{8}-[0-9]{4}$'),
    CHECK (zip_code ~ '^[0-9]{5}$')
);

CREATE TABLE contact_details (
    contact_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    school_id INT NOT NULL REFERENCES person (school_id) ON DELETE CASCADE,
    is_personal BOOLEAN NOT NULL,  
    belongs_to VARCHAR(50),
    phone_number VARCHAR(15),
    email VARCHAR(320),
    CONSTRAINT contact_details_PK PRIMARY KEY (contact_id, school_id),
    CHECK (phone_number IS NOT NULL OR email IS NOT NULL)
);

CREATE TABLE student (
    student_school_id INT NOT NULL REFERENCES person (school_id) ON DELETE CASCADE,
    sibling_id INT,
    CONSTRAINT student_PK PRIMARY KEY (student_school_id)
);

CREATE TABLE instructor (
    instructor_school_id INT NOT NULL REFERENCES person (school_id) ON DELETE CASCADE,
    can_teach_ensamble BOOLEAN,
    CONSTRAINT instructor_PK PRIMARY KEY (instructor_school_id)
);

CREATE TABLE instrument_skill (
    instrument_type INT NOT NULL,
    instructor_school_id INT NOT NULL REFERENCES instructor (instructor_school_id) ON DELETE CASCADE,
    skill_level SMALLINT NOT NULL,
    CONSTRAINT instrument_skill_PK PRIMARY KEY (instrument_type, instructor_school_id),
    CHECK (skill_level BETWEEN 1 AND 3)
);

CREATE TABLE instrument (
    inventory_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    instrument_type INT NOT NULL,
    brand VARCHAR(100),
    model VARCHAR(100),
    quantity INT NOT NULL,
    rental_cost MONEY NOT NULL,
    CONSTRAINT instrument_PK PRIMARY KEY (inventory_id),
    CHECK (quantity >= 0),
    CHECK (rental_cost >= 0::money)
);

CREATE TABLE rental (
    rental_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    is_paid_for BOOLEAN NOT NULL DEFAULT FALSE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    school_id INT NOT NULL REFERENCES person (school_id),
    inventory_id INT NOT NULL REFERENCES instrument (inventory_id),
    CONSTRAINT rental_PK PRIMARY KEY (rental_id),
    CHECK (end_date > start_date),
    CHECK (end_date <= start_date + INTERVAL '12 months')
);

-- Restrict rentals to not be more than 2
CREATE OR REPLACE FUNCTION check_max_rentals() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM rental WHERE end_date >= CURRENT_DATE AND school_id = NEW.school_id) >= 2 THEN
        RAISE EXCEPTION 'Student cannot have more than 2 active rentals.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER max_rentals_trigger BEFORE INSERT ON rental
FOR EACH ROW EXECUTE FUNCTION check_max_rentals();


CREATE TABLE location (
    location_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    room_name VARCHAR(25),
    video_link VARCHAR(999),
    CONSTRAINT location_PK PRIMARY KEY (location_id),
    CHECK (room_name IS NOT NULL OR video_link IS NOT NULL)
);

CREATE TABLE pricing (
    price_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    skill_level SMALLINT NOT NULL,
    activity_type INT NOT NULL,
    price MONEY NOT NULL,
    sibling_discount DECIMAL(5,2),
    CONSTRAINT pricing_PK PRIMARY KEY (price_id),
    CHECK (activity_type BETWEEN 1 AND 3),
    CHECK (skill_level BETWEEN 1 AND 3),
    CHECK (price >= 0::money),
    CHECK (sibling_discount BETWEEN 1 AND 100)
);

CREATE TABLE activity (
    activity_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    instructor_school_id INT NOT NULL REFERENCES instructor (instructor_school_id),
    location_id INT NOT NULL REFERENCES location (location_id),
    price_id INT NOT NULL REFERENCES pricing (price_id),
    start_time TIMESTAMP(6) NOT NULL,
    end_time TIMESTAMP(6) NOT NULL,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    CONSTRAINT activity_PK PRIMARY KEY (activity_id),
    CHECK (end_time > start_time)
);

CREATE TABLE booking (
    student_school_id INT NOT NULL REFERENCES student (student_school_id),
    activity_id INT NOT NULL REFERENCES activity (activity_id),
    is_paid_for BOOLEAN DEFAULT FALSE,
    CONSTRAINT booking_PK PRIMARY KEY (student_school_id, activity_id)
);

CREATE TABLE lesson (
    activity_id INT NOT NULL REFERENCES activity (activity_id) ON DELETE CASCADE,
    instrument_type INT NOT NULL,
    skill_level SMALLINT NOT NULL,
    min_students SMALLINT,
    max_students SMALLINT,
    CONSTRAINT lesson_PK PRIMARY KEY (activity_id),
    CHECK (skill_level BETWEEN 1 AND 3),
    CHECK (min_students IS NULL OR min_students > 0),
    CHECK (max_students IS NULL OR max_students > 0),
    CHECK (max_students IS NULL OR max_students >= min_students)
);

CREATE TABLE ensamble (
    activity_id INT NOT NULL REFERENCES activity (activity_id) ON DELETE CASCADE,
    genre VARCHAR(99) NOT NULL,
    min_students SMALLINT NOT NULL,
    max_students SMALLINT NOT NULL,
    CONSTRAINT ensamble_PK PRIMARY KEY (activity_id),
    CHECK (max_students >= min_students),
    CHECK (min_students > 0)
);