CREATE TABLE person (
    school_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    personal_id_number CHAR(13) NOT NULL UNIQUE,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    address VARCHAR(100),
    zip_code CHAR(5),
    city VARCHAR(100),
    CONSTRAINT person_PK PRIMARY KEY (school_id),
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
    CONSTRAINT contact_details_PK PRIMARY KEY (contact_id),
    CHECK (phone_number IS NOT NULL OR email IS NOT NULL)
);

CREATE TABLE student (
    student_school_id INT NOT NULL REFERENCES person (school_id) ON DELETE CASCADE,
    CONSTRAINT student_PK PRIMARY KEY (student_school_id)
);

CREATE TABLE sibling (
    student_school_id_first INT NOT NULL REFERENCES student(student_school_id) ON DELETE CASCADE,
    student_school_id_second INT NOT NULL REFERENCES student(student_school_id) ON DELETE CASCADE,
    CONSTRAINT sibling_PK PRIMARY KEY (student_school_id_first, student_school_id_second),
    CHECK (student_school_id_first != student_school_id_second)
);

-- Ensure student_school_id_first and student_school_id_second is enforced
CREATE OR REPLACE FUNCTION enforce_sibling_order() RETURNS TRIGGER AS $$
DECLARE temp INT;
BEGIN
    IF (NEW.student_school_id_first > NEW.student_school_id_second) THEN
        temp := NEW.student_school_id_first;
        NEW.student_school_id_first := NEW.student_school_id_second;
        NEW.student_school_id_second := temp;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER enforce_sibling_order BEFORE INSERT OR UPDATE ON sibling
FOR EACH ROW EXECUTE FUNCTION enforce_sibling_order();

CREATE TABLE instructor (
    instructor_school_id INT NOT NULL REFERENCES person (school_id) ON DELETE CASCADE,
    can_teach_ensamble BOOLEAN,
    CONSTRAINT instructor_PK PRIMARY KEY (instructor_school_id)
);

CREATE TABLE instrument_type (
    instrument_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    instrument_name VARCHAR(25) NOT NULL,
    CONSTRAINT instrument_type_PK PRIMARY KEY (instrument_id)
);

CREATE TABLE instrument_skill (
    instrument_type INT NOT NULL REFERENCES instrument_type (instrument_id) ON DELETE CASCADE,
    instructor_school_id INT NOT NULL REFERENCES instructor (instructor_school_id) ON DELETE CASCADE,
    skill_level SMALLINT NOT NULL,
    CONSTRAINT instrument_skill_PK PRIMARY KEY (instrument_type, instructor_school_id),
    CHECK (skill_level BETWEEN 1 AND 3)
);

CREATE TABLE instrument (
    inventory_id INT GENERATED ALWAYS AS IDENTITY NOT NULL,
    instrument_type INT NOT NULL REFERENCES instrument_type (instrument_id) ON DELETE RESTRICT,
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
    school_id INT NOT NULL REFERENCES person (school_id) ON DELETE CASCADE,
    inventory_id INT NOT NULL REFERENCES instrument (inventory_id) ON DELETE CASCADE,
    CONSTRAINT rental_PK PRIMARY KEY (rental_id),
    CHECK (end_date > start_date),
    CHECK (end_date <= start_date + INTERVAL '12 months')
);

-- Restrict rentals to not be more than 2
CREATE OR REPLACE FUNCTION check_max_rentals() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR NEW.end_date != OLD.end_date OR NEW.school_id != OLD.school_id) THEN
        IF (SELECT COUNT(*) FROM rental WHERE rental_id != NEW.rental_id AND end_date >= CURRENT_DATE AND school_id = NEW.school_id) >= 2 THEN
            RAISE EXCEPTION 'Student cannot have more than 2 active rentals.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER max_rentals_trigger BEFORE INSERT OR UPDATE ON rental
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
    instructor_school_id INT NOT NULL REFERENCES instructor (instructor_school_id) ON DELETE RESTRICT,
    location_id INT NOT NULL REFERENCES location (location_id) ON DELETE RESTRICT,
    price_id INT NOT NULL REFERENCES pricing (price_id) ON DELETE RESTRICT,
    start_time TIMESTAMP(6) NOT NULL,
    end_time TIMESTAMP(6) NOT NULL,
    title VARCHAR(100) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    CONSTRAINT activity_PK PRIMARY KEY (activity_id),
    CHECK (end_time > start_time)
);

-- Restrict instructor to not be double booked
CREATE OR REPLACE FUNCTION check_instructor_double_bookings() RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM activity WHERE activity_id != NEW.activity_id AND instructor_school_id = NEW.instructor_school_id AND NEW.start_time < end_time AND NEW.end_time > start_time) THEN
        RAISE EXCEPTION 'Instructor cannot be booked on more than one activity at a time.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER instructor_double_booking_trigger BEFORE INSERT OR UPDATE ON activity
FOR EACH ROW EXECUTE FUNCTION check_instructor_double_bookings();

CREATE TABLE booking (
    student_school_id INT NOT NULL REFERENCES student (student_school_id) ON DELETE CASCADE,
    activity_id INT NOT NULL REFERENCES activity (activity_id) ON DELETE CASCADE,
    is_paid_for BOOLEAN DEFAULT FALSE,
    CONSTRAINT booking_PK PRIMARY KEY (student_school_id, activity_id)
);

CREATE TABLE lesson_individual (
    activity_id INT NOT NULL REFERENCES activity (activity_id) ON DELETE CASCADE,
    instrument_type INT NOT NULL REFERENCES instrument_type (instrument_id) ON DELETE RESTRICT,
    skill_level SMALLINT NOT NULL,
    CONSTRAINT lesson_individual_PK PRIMARY KEY (activity_id),
    CHECK (skill_level BETWEEN 1 AND 3)
);

CREATE TABLE lesson_group (
    activity_id INT NOT NULL REFERENCES activity (activity_id) ON DELETE CASCADE,
    instrument_type INT NOT NULL REFERENCES instrument_type (instrument_id) ON DELETE RESTRICT,
    skill_level SMALLINT NOT NULL,
    min_students SMALLINT NOT NULL,
    max_students SMALLINT NOT NULL,
    CONSTRAINT lesson_group_PK PRIMARY KEY (activity_id),
    CHECK (skill_level BETWEEN 1 AND 3),
    CHECK (min_students > 0),
    CHECK (max_students >= min_students)
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