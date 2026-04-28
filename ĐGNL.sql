DROP DATABASE IF EXISTS db_test;
CREATE DATABASE db_test;
USE db_test;

-- 1. Tạo bảng 
CREATE TABLE Members (
	member_id VARCHAR(5) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    membership_type VARCHAR(50),
    join_date DATE
);

CREATE TABLE Trainers (
	trainer_id VARCHAR(5) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    experience INT NOT NULL,
    salary DECIMAL(12,2) NOT NULL
);

CREATE TABLE Classes (
	class_id VARCHAR(5) PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL UNIQUE,
    trainer_id VARCHAR(5) NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES Trainers(trainer_id),
    schedule_time DATETIME NOT NULL,
    max_capacity INT NOT NULL,
    fee DECIMAL(10,2) NOT NULL
);

CREATE TABLE Enrollments (
	enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    class_id VARCHAR(5) NOT NULL,
    FOREIGN KEY (class_id) REFERENCES Classes(class_id),
    member_id VARCHAR(5) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES Members(member_id),
    status VARCHAR(20) NOT NULL,
    enroll_date DATE NOT NULL
);

-- 2. Chèn dữ liệu 
INSERT INTO Members VALUES
('M01', 'Nguyễn Văn An', 'an.nguyen@gmail.com', '0912345678', 'Premium', '2025-01-15'),
('M02', 'Trần Thị Bình', 'binh.tran@gmail.com', '0987654321', 'VIP', '2025-02-20'),
('M03', 'Lê Hoàng Cường', 'cuong.le@gmail.com', '0978123456', 'Basic', '2025-03-10'),
('M04', 'Phạm Minh Dũng', 'dung.pham@gmail.com', '0909876543', 'Premium', '2025-04-05');

INSERT INTO Trainers VALUES
('T01', 'Coach Alex', 'Strength Training', 8, 25000000.00),
('T02', 'Huấn luyện viên Lan', 'Yoga & Pilates', 6, 18000000.00),
('T03', 'Coach Minh', 'Functional Fitness', 10, 30000000.00);

INSERT INTO Classes VALUES
('C01', 'Morning Strength', 'T01', '2025-11-10 06:30:00', 20, 150000.00),
('C02', 'Yoga Flow', 'T02', '2025-11-10 17:30:00', 15, 120000.00),
('C03', 'HIIT Burn', 'T03', '2025-11-11 18:00:00', 18, 180000.00),
('C04', 'Power Lifting', 'T01', '2025-11-12 07:00:00', 12, 200000.00);

INSERT INTO Enrollments VALUES
(1, 'C01', 'M01', 'Confirmed', '2025-11-01'),
(2, 'C02', 'M02', 'Confirmed', '2025-11-02'),
(3, 'C01', 'M03', 'Canceled', '2025-11-03'),
(4, 'C04', 'M01', 'Confirmed', '2025-11-05'),
(5, 'C03', 'M04', 'Pending', '2025-11-06');

-- 4. Lớp C03 (HIIT Burn) có nhu cầu cao → tăng học phí (fee) thêm 20%.
UPDATE Classes
SET fee = fee * 1.2
WHERE class_id = 'C03';

-- 5. Cập nhật membership_type của thành viên M02 thành 'VIP Elite'.
UPDATE Members
SET membership_type = 'VIP Elite'
WHERE member_id = 'M02';

-- 6. Xóa tất cả các đơn đăng ký có trạng thái 'Canceled'.
DELETE FROM Enrollments
WHERE status = 'Canceled';

-- 7. Thêm ràng buộc cho cột fee trong bảng Classes: học phí phải >= 0.
ALTER TABLE Classes
ADD CONSTRAINT check_fee CHECK (fee >= 0);

-- 8. Thiết lập giá trị mặc định cho cột status trong bảng Enrollments là 'Pending'.
ALTER TABLE Enrollments
MODIFY status VARCHAR(20) NOT NULL DEFAULT 'Pending';

-- 9. Thêm cột gender (VARCHAR(10)) vào bảng Members sau khi tạo bảng (giá trị có thể là 'Male', 'Female', 'Other').
ALTER TABLE Members
ADD COLUMN gender VARCHAR(10);

-- 10. Liệt kê tất cả các lớp học có chuyên môn liên quan đến "Strength" hoặc "Fitness".
SELECT c.* FROM Classes AS c
JOIN Trainers AS t 
ON c.trainer_id = t.trainer_id
WHERE t.specialty LIKE '%Strength%' OR t.specialty LIKE '%Fitness%';

-- 11. Lấy thông tin full_name, email của những thành viên có tên chứa ký tự 'n' .
SELECT full_name, email FROM Members
WHERE full_name LIKE '%n%';

-- 12. Hiển thị danh sách các lớp học gồm class_id, class_name, schedule_time, sắp xếp theo schedule_time tăng dần.
SELECT class_id, class_name, schedule_time FROM Classes
ORDER BY schedule_time;

-- 13. Lấy ra 3 lớp học có học phí (fee) thấp nhất.
SELECT * FROM Classes
ORDER BY fee
LIMIT 3;

-- 14. Hiển thị class_name, specialty từ bảng Classes và Trainers, bỏ qua lớp đầu tiên và lấy 2 lớp tiếp theo.
SELECT c.class_name, t.specialty
FROM Classes AS c
JOIN Trainers AS t
ON c.trainer_id = t.trainer_id
LIMIT 2 OFFSET 1;

-- 15. Giảm 15% học phí cho tất cả các lớp học diễn ra vào buổi sáng (trước 12:00).
UPDATE Classes
SET fee = fee * 0.85
WHERE TIME(schedule_time) < '12:00:00';

-- 16. Chuyển đổi toàn bộ full_name của thành viên trong bảng Members thành chữ in hoa
UPDATE Members
SET full_name = UPPER(full_name);

-- 17. Xóa tất cả các lớp học có học phí bằng 0 (nếu có) và đảm bảo xử lý ràng buộc khóa ngoại với bảng Enrollments.
DELETE FROM Enrollments
WHERE class_id IN (
    SELECT class_id FROM Classes 
    WHERE fee = 0
);
DELETE FROM Classes
WHERE fee = 0;

-- 18. Hiển thị enrollment_id, full_name (thành viên), class_name, full_name(trainer) → thay bằng trainer_full_name của các đơn đăng ký có trạng thái 'Confirmed'.
SELECT e.enrollment_id, m.full_name, c.class_name, t.full_name AS trainer_full_name
FROM Enrollments AS e
JOIN Members AS m 
ON e.member_id = m.member_id
JOIN Classes AS c 
ON e.class_id = c.class_id
JOIN Trainers AS t 
ON c.trainer_id = t.trainer_id
WHERE e.status = 'Confirmed';

-- 19. Liệt kê tất cả các lớp học (class_name) và thời gian (schedule_time) tương ứng. Hiển thị cả những lớp chưa có thành viên nào đăng ký.
SELECT c.class_name, c.schedule_time
FROM Classes AS c
LEFT JOIN Enrollments AS e 
ON c.class_id = e.class_id;

-- 20. Tính tổng số đơn đăng ký theo từng trạng thái (status) 
SELECT status, COUNT(*) AS total
FROM Enrollments
GROUP BY status;

-- 21. Thống kê số lượng lớp học mà mỗi thành viên đã đăng ký. Chỉ hiển thị những thành viên đăng ký từ 2 lớp trở lên.
SELECT m.full_name, COUNT(e.class_id) AS total_classes
FROM Members AS m
JOIN Enrollments AS e 
ON m.member_id = e.member_id
GROUP BY m.member_id, m.full_name
HAVING total_classes >= 2;

-- 22. Lấy thông tin các lớp học có học phí thấp hơn học phí trung bình của tất cả các lớp.
SELECT * FROM Classes
WHERE fee < (
	SELECT AVG(fee) FROM Classes
);

-- 23. Hiển thị full_name và membership_type của những thành viên đã đăng ký tham gia lớp "Morning Strength".
SELECT m.full_name, m.membership_type
FROM Members AS m
JOIN Enrollments AS e 
ON m.member_id = e.member_id
JOIN Classes AS c 
ON e.class_id = c.class_id
WHERE c.class_name = 'Morning Strength';

-- 24. Liệt kê danh sách các lớp học diễn ra trong tháng 11 năm 2025.
SELECT * FROM Classes
WHERE schedule_time BETWEEN '2025-11-01' AND '2025-11-30';
