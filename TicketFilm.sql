-- Tạo DDL
CREATE DATABASE TicketFilm;

USE TicketFilm;

CREATE TABLE tblPhim (
    PhimId INT PRIMARY KEY AUTO_INCREMENT,
    Ten_phim NVARCHAR(30),
    loai_phim NVARCHAR(25),
    Thoi_gian INT
);
DROP TABLE tblphim;
CREATE TABLE tblPhong(
    PhongId INT PRIMARY KEY AUTO_INCREMENT,
    Ten_phong NVARCHAR(20),
    Trang_thai TINYINT
);
CREATE TABLE tblGhe(
    GheId INT PRIMARY KEY AUTO_INCREMENT,
    PhongId int,
    So_ghe VARCHAR(10)
);
-- Chỉ định khoá ngoại
ALTER TABLE tblGhe 
ADD CONSTRAINT FK_Phong_ID FOREIGN KEY (PhongId) REFERENCES tblPhong(PhongId);

CREATE TABLE tblVe(
    PhimId int,
    GheId int,
    Ngay_chieu DATETIME,
    Trang_thai NVARCHAR(20) 
);
-- Chỉ định khóa ngoại
ALTER TABLE tblve
ADD CONSTRAINT FK_Phim_Id FOREIGN KEY (PhimId) REFERENCES tblphim(PhimId);
ALTER TABLE tblve
ADD CONSTRAINT FK_Ghe_Id FOREIGN KEY (GheId) REFERENCES tblghe(GheId);

-- DML tạo dữ liệu
INSERT INTO tblphim(Ten_phim, loai_phim, Thoi_gian) VALUES
('Em bé Hà Nội','Tâm lý', 90),
('Nhiệm vụ bất khả thi','Hành động', 100),
('Dị nhân','Viễn tưởng', 90),
('Cuốn theo chiều gió','Tình cảm',120);
INSERT INTO tblphong(Ten_phong,Trang_thai) VALUES
('Phòng chiếu 1',1),
('Phòng chiếu 2',1),
('Phòng chiếu 3',0);
INSERT INTO tblghe(GheId,PhongId,So_ghe) VALUES
(1,1,'A3'),
(2,1,'B5'),
(3,2,'A7'),
(4,2,'D1'),
(5,3,'T2');
INSERT INTO tblve(PhimId,GheId,Ngay_chieu,Trang_thai) VALUES
(1,1,'2008-10-20','Đã bán'),
(1,3,'2008-11-20','Đã bán'),
(1,4,'2008-12-23','Đã bán'),
(2,1,'2009-02-14','Đã bán'),
(3,1,'2009-02-14','Đã bán'),
(2,5,'2009-03-08','Chưa bán'),
(2,3,'2009-03-08','Chưa bán');

-- DML Truy Vấn
-- 2.	Hiển thị danh sách các phim (chú ý: danh sách phải được sắp xếp theo trường Thoi_gian)
CREATE VIEW VW_MOvie_List_Sorted_By_Date
AS
    SELECT *
        FROM tblphim m
        ORDER BY m.Thoi_gian ASC
;
SELECT * FROM vw_movie_list_sorted_by_date;

-- 3.	Hiển thị Ten_phim có thời gian chiếu dài nhất
SELECT m.Ten_phim
    FROM tblphim m
    WHERE m.Thoi_gian = (SELECT max(vw.Thoi_gian) FROM vw_movie_list_sorted_by_date as vw)
;

-- 4.	Hiển thị Ten_Phim có thời gian chiếu ngắn nhất
SELECT m.Ten_phim
    FROM tblphim m
    WHERE m.Thoi_gian = (SELECT min(vw.Thoi_gian) FROM vw_movie_list_sorted_by_date as vw)
;

-- 5.	Hiển thị danh sách So_Ghe mà bắt đầu bằng chữ ‘A’
CREATE INDEX IDX_SO_GHE ON tblghe (So_ghe);

CREATE VIEW VW_Search_Seat_Number_By_Key
AS
    SELECT s.So_ghe
        FROM tblghe s
        WHERE s.So_ghe LIKE 'A%'
;
SELECT * FROM vw_search_seat_number_by_key;

-- 6.	Sửa cột Trang_thai của bảng tblPhong sang kiểu nvarchar(25)
ALTER TABLE tblphong
MODIFY COLUMN Trang_thai nvarchar(25);

-- 7.	Cập nhật giá trị cột Trang_thai của bảng tblPhong theo các luật sau:
-- •	Nếu Trang_thai=0 thì gán Trang_thai=’Đang sửa’
-- •	Nếu Trang_thai=1 thì gán Trang_thai=’Đang sử dụng’
-- •	Nếu Trang_thai=null thì gán Trang_thai=’Unknow’
-- Sau đó hiển thị bảng tblPhong
UPDATE tblphong
SET Trang_thai = 'Đang sửa' WHERE Trang_thai = '0';
UPDATE tblphong
SET Trang_thai = 'Đang sử dụng' WHERE Trang_thai = '1';
UPDATE tblphong
SET Trang_thai = 'Unknow' WHERE Trang_thai = null;
SELECT * FROM tblphong;

-- 8.	Hiển thị danh sách tên phim mà có độ dài >15 và < 25 ký tự
CREATE VIEW VW_Movie_List_By_Movie_Length
AS
    SELECT m.Ten_phim,
        REPLACE(m.Ten_phim,' ','') AS Trimed_Ten_Phim
        FROM tblphim m
        HAVING LENGTH(Trimed_Ten_Phim) > 15 AND LENGTH(Trimed_Ten_Phim) < 25
;
DROP VIEW vw_movie_list_by_movie_length;
SELECT * FROM vw_movie_list_by_movie_length;

-- 9.	Hiển thị Ten_Phong và Trang_Thai trong bảng tblPhong trong 1 cột với tiêu đề ‘Trạng thái phòng chiếu’
SELECT CONCAT(r.Ten_phong,' / ',r.Trang_thai) AS 'Trạng thái phòng chiếu'
    FROM tblphong r
;

-- 10.	Tạo bảng mới có tên tblRank với các cột sau: STT(thứ hạng sắp xếp theo Ten_Phim), TenPhim, Thoi_gian
CREATE TABLE tblRank(
    STT int PRIMARY KEY AUTO_INCREMENT,
    TenPhim VARCHAR(30),
    Thoi_gian int
);

DELIMITER //
CREATE TRIGGER ins_tblrank AFTER INSERT ON tblPhim
FOR EACH ROW
BEGIN
    DELETE FROM tblRank;
    SET @AUTO_INCREMENT = 1;
    INSERT INTO tblRank (TenPhim,Thoi_gian) SELECT m.Ten_phim,m.Thoi_gian FROM tblphim m
    ORDER BY m.Ten_Phim ASC ;
END;
//
DELIMITER ;

-- 11.	Trong bảng tblPhim :
-- a. Thêm trường Mo_ta kiểu nvarchar(max)
ALTER TABLE tblphim
ADD COLUMN Mo_ta NVARCHAR(4000);
ALTER TABLE tblphim
DROP COLUMN Mo_ta;
-- 11.b. Cập nhật trường Mo_ta: thêm chuỗi “Đây là bộ phim thể loại ” + nội dung trường LoaiPhim
UPDATE tblPhim
SET Mo_ta = CONCAT('Đây là bộ phim thể loại ',tblPhim.loai_phim) WHERE loai_phim IS NOT NULL;
-- 11.c. Hiển thị bảng tblPhim sau khi cập nhật
SELECT * FROM tblphim;
-- 11. d. Cập nhật trường Mo_ta: thay chuỗi “bộ phim” thành chuỗi “film”
UPDATE tblphim
SET Mo_ta = REPLACE(Mo_ta,'bộ phim','film') WHERE Mo_ta IS NOT NULL;
-- 11.e. Hiển thị bảng tblPhim sau khi cập nhật
SELECT * FROM tblphim;

-- 12.	Xóa tất cả các khóa ngoại trong các bảng trên.
SHOW CREATE TABLE tblGhe;
ALTER TABLE tblghe
DROP CONSTRAINT FK_Phong_ID;
ALTER TABLE tblve
DROP CONSTRAINT FK_Ghe_Id,
DROP CONSTRAINT FK_Phim_Id;

-- 13.	Xóa dữ liệu ở bảng tblGhe
DELETE FROM tblghe;

-- 14.	Hiển thị ngày giờ hiện tại và ngày giờ hiện tại cộng thêm 5000 phút
SELECT CURRENT_TIMESTAMP as current_date_time, TIMESTAMPADD(MINUTE,5000,CURRENT_TIMESTAMP) as current_plus_5000min_date_time,
        CONCAT(ROUND(5000/(1440)),' ngày ',ROUND((5000%1440)/60),' giờ ',5000%60,' phút ') as convert_5000_Minutes;