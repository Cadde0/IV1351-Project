-- Add more persons
INSERT INTO person (personal_id_number, first_name, last_name, date_of_birth, address, zip_code, city) 
VALUES 
('19811113-6763', 'John', 'Appleseed', '1981-11-13', 'Storgatan 3', '14241', 'Tuatuka'),
('19900521-1234', 'Jane', 'Doe', '1990-05-21', 'Mellangatan 5', '12345', 'Springfield'),
('19850710-4321', 'John', 'Smith', '1985-07-10', 'Lillgatan 9', '54321', 'Shelbyville'),
('19811113-6764', 'Will', 'Appleseed', '1981-11-13', 'Storgatan 3', '14241', 'Tuatuka'),
('20020314-5566', 'Emma', 'Brown', '2002-03-14', 'Brogatan 12', '56789', 'Sunnydale'),
('19970721-6677', 'Lucas', 'Green', '1997-07-21', 'Parkvägen 7', '23456', 'Hilltown'),
('19890115-7788', 'Sophia', 'White', '1989-01-15', 'Riverside 9', '98765', 'Riverdale');

-- Insert students
INSERT INTO student (student_school_id)
VALUES 
(1),
(2),
(4),
(5),
(6);

-- Insert siblings
INSERT INTO sibling (student_school_id_first, student_school_id_second)
VALUES 
(4, 1),
(5, 6);

-- Insert instructors
INSERT INTO instructor (instructor_school_id, can_teach_ensamble) 
VALUES 
(3, false),
(7, true);

-- Insert instrument_types
INSERT INTO instrument_type (instrument_name)
VALUES
('Guitar'),
('Piano'),
('Drums'),
('Violin'),
('Flute');

-- Insert contact details
INSERT INTO contact_details (school_id, is_personal, belongs_to, phone_number, email)
VALUES 
(1, TRUE, 'John Appleseed', '0702357645', 'john.appleseed@example.com'),
(2, TRUE, 'Jane Doe', '0735416452', 'jane.doe@example.com'),
(3, TRUE, 'John Smith', '0742549674', 'john.smith@example.com'),
(5, TRUE, 'Emma Brown', '0751234567', 'emma.brown@example.com'),
(6, TRUE, 'Lucas Green', '0767654321', 'lucas.green@example.com'),
(1, false, 'Parent', '070322145', NULL),
(5, false, 'Guardian', '0759876543', 'guardian.brown@example.com');

-- Add instruments
INSERT INTO instrument_inventory (instrument_type, brand, model, quantity, rental_cost) 
VALUES 
(1, 'Yamaha', 'FG800', 10, 25.00),
(2, 'Stradivarius', 'Model X', 5, 50.00),
(3, 'Steinway', 'Grand Model B', 2, 200.00),
(4, 'Fender', 'Stratocaster', 6, 30.00),
(5, 'Pearl', 'Roadshow', 4, 40.00);

-- Add instrument skills
INSERT INTO instrument_skill (instrument_type, instructor_school_id, skill_level) 
VALUES 
(1, 3, 3),
(2, 3, 2),
(4, 7, 3),
(5, 7, 1);

-- Add rental records
INSERT INTO rental (is_paid_for, start_date, end_date, school_id, inventory_id) 
VALUES 
(TRUE, '2024-01-01', '2024-06-01', 2, 1),
(FALSE, '2024-01-15', '2024-07-15', 1, 2),
(TRUE, '2024-02-01', '2024-08-01', 5, 4);

-- Add locations
INSERT INTO location (room_name, video_link) 
VALUES 
('Room A', 'https://example.com/roomA'),
('Room B', 'https://example.com/roomB'),
('Room C', NULL),
(NULL, 'example.com/room-d'),
('Studio 1', 'https://example.com/studio1');

-- Add pricing
INSERT INTO pricing (skill_level, activity_type, price, sibling_discount) 
VALUES 
(1, 1, 15.00, 10),
(2, 2, 25.00, 15),
(3, 1, 50.00, 20);

-- Add activities
INSERT INTO activity (instructor_school_id, location_id, price_id, start_time, end_time, title, description) 
VALUES 
(3, 1, 1, '2024-11-20 10:00:00', '2024-11-20 12:00:00', 'Private Guitar Lesson', 'Learn the basics of guitar'),
(3, 1, 1, '2024-11-20 12:00:00', '2024-11-20 15:00:00', 'Guitar Workshop', 'Learn the basics of guitar in group.'),
(3, 2, 2, '2024-11-21 14:00:00', '2024-11-21 16:00:00', 'Violin Ensemble', 'Practice advanced violin techniques'),
(7, 4, 3, '2024-11-22 10:00:00', '2024-11-22 12:00:00', 'Drum Practice', 'Intermediate drumming techniques'),
(7, 3, 3, '2024-11-23 14:00:00', '2024-11-23 16:00:00', 'Rock Guitar Masterclass', 'Advanced techniques for electric guitar.');

-- Add lessons
INSERT INTO lesson_individual (activity_id, instrument_type, skill_level)
VALUES 
(1, 1, 1),
(4, 5, 2);

INSERT INTO lesson_group (activity_id, instrument_type, skill_level, min_students, max_students) 
VALUES
(2, 2, 2, 3, 10),
(3, 4, 3, 5, 15);

-- Add bookings
INSERT INTO booking (student_school_id, activity_id, is_paid_for) 
VALUES 
(2, 1, TRUE),
(1, 2, FALSE),
(5, 4, TRUE);

-- Add ensembles
INSERT INTO ensamble (activity_id, genre, min_students, max_students) 
VALUES 
(3, 'Classical', 3, 10),
(5, 'Rock', 5, 20);
