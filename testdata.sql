-- Add more persons
INSERT INTO person (personal_id_number, first_name, last_name, date_of_birth, address, zip_code, city) 
VALUES 
('82484573-6763', 'John', 'Appleseed', '1981-11-13', 'Storgatan 3', '14241', 'Tuatuka'),
('12345678-1234', 'Jane', 'Doe', '1990-05-21', 'Mellangatan 5', '12345', 'Springfield'),
('87654321-4321', 'John', 'Smith', '1985-07-10', 'Lillgatan 9', '54321', 'Shelbyville');

-- Insert students
INSERT INTO student (school_id) 
SELECT school_id FROM person WHERE first_name IN ('Jane', 'John');

-- Insert instructors
INSERT INTO instructor (school_id, can_teach_ensamble)
SELECT school_id, TRUE FROM person WHERE first_name = 'Hector';

-- Insert contact details
INSERT INTO contact_details (school_id, is_personal, belongs_to, phone_number, email)
VALUES 
(1, TRUE, 'John Appleseed', '0702357645', 'hector@example.com'),
(2, TRUE, 'Jane Doe', '0735416452', 'jane@example.com'),
(3, TRUE, 'John Smith', '0742549674', 'john@example.com');

-- Add instruments
INSERT INTO instrument (instrument_type, brand, model, quantity, rental_cost) 
VALUES 
('Guitar', 'Yamaha', 'FG800', 10, 25.00),
('Violin', 'Stradivarius', 'Model X', 5, 50.00),
('Piano', 'Steinway', 'Grand Model B', 2, 200.00);

-- Add instrument skills
INSERT INTO instrument_skill (instrument_type, instructor_school_id, skill_level) 
VALUES 
('Guitar', 1, 3),
('Violin', 1, 2);

-- Add rental records
INSERT INTO rental (is_paid_for, start_date, end_date, school_id, inventory_id) 
VALUES 
(TRUE, '2024-01-01', '2024-06-01', 2, 1),
(FALSE, '2024-01-15', '2024-07-15', 3, 2);

-- Add locations
INSERT INTO location (room_name, video_link) 
VALUES 
('Room A', 'https://example.com/roomA'),
('Room B', 'https://example.com/roomB');

-- Add pricing
INSERT INTO pricing (active, skill_level, activity_type, price, sibling_discount) 
VALUES 
(TRUE, 1, 1, 15.00, 0.10),
(TRUE, 2, 2, 25.00, 0.15);

-- Add activities
INSERT INTO activity (instructor_school_id, location_id, price_id, start_time, end_time, title, description) 
VALUES 
(1, 1, 1, '2024-11-20 10:00:00', '2024-11-20 12:00:00', 'Guitar Workshop', 'Learn the basics of guitar'),
(1, 2, 2, '2024-11-21 14:00:00', '2024-11-21 16:00:00', 'Violin Ensemble', 'Practice advanced violin techniques');

-- Add lessons
INSERT INTO lesson (activity_id, instrument_type, skill_level, min_students, max_students) 
VALUES 
(1, 'Guitar', 1, 5, 15),
(2, 'Violin', 2, 3, 10);

-- Add bookings
INSERT INTO booking (student_school_id, activity_id, is_paid_for) 
VALUES 
(2, 1, TRUE),
(3, 2, FALSE);

-- Add ensembles
INSERT INTO ensamble (activity_id, genre, min_students, max_students) 
VALUES 
(2, 'Classical', 3, 10);
