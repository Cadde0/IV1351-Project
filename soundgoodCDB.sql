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