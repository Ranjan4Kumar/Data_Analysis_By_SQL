/* Instagram Clone Exploratory Data Analysis Using SQL */
/* SQL Skills : Joins , data manipulation, regular expression, views, sorted procedure, aggregate functions, string manipulation */

-- -------------------------------------------------------------------------------------------------------------------------------
/*Q1: The 1st 10 users on the platform */

select * from ig_clone.users
order by created_at asc
limit 10;
-- -------------------------------------------------------------------------------------------------------------------------------

/*Q2: Total number of registrations */
SELECT COUNT(*) AS 'Total Registration'
FROM
ig_clone.users;
-- -------------------------------------------------------------------------------------------------------------------------------

/* Q3: The day of the week most users register on */
CREATE VIEW vwtotalregistrations AS
SELECT
DATE_FORMAT(created_at, '%w') AS 'day of the week',
COUNT(*) AS 'total number of registation'
FROM
ig_clone.users
GROUP BY 1
ORDER BY 2 DESC;

SELECT * FROM vwtotalregistrations;

/* virsion 2*/

SELECT
	DAYNAME(created_at) AS 'Day of the week',
    COUNT(*) AS 'Total registration' 
FROM
	ig_clone.users
GROUP BY 1
ORDER BY 2 DESC;

-- -------------------------------------------------------------------------------------------------------------------------------

/*Q4 : The users who have never posted a photo */

SELECT 
	u.username
FROM
	ig_clone.users u
		LEFT JOIN
	ig_clone.photos p ON p.user_id
    WHERE p.id IS NULL;
    
    
/*This SQL query is selecting the "username" column from the "users" table in a database schema called "ig_clone". 
The alias "u" is assigned to the "users" table for convenience, allowing us to reference the table using a shorter name in the query.

The "SELECT" statement specifies which column(s) to retrieve data from, and in this case, we are retrieving the "username" column from the "users" table.

The "FROM" clause specifies the table(s) that the data is being retrieved from, and in this case, it is the "users" table in the "ig_clone" database schema.

So overall, this query is selecting the usernames of all users in the "users" table in the "ig_clone" database schema. */

-- -------------------------------------------------------------------------------------------------------------------------------

/*Q5 The most likes on a single photo */

SELECT 
	u.username, p.image_url, COUNT(*) AS total
FROM
	ig_clone.photos p
		INNER JOIN
	ig_clone.likes l ON l.photo_id = p.id
		INNER JOIN
	ig_clone.users u ON p.user_id = u.id
GROUP BY p.id
ORDER BY total DESC
LIMIT 1;
					/* version 2*/
                    
/* Average posts by user */

SELECT 
	ROUND((SELECT
					COUNT(*)
				FROM 
					ig_clone.photos)/(SELECT COUNT(*)
				FROM
					ig_clone.users),
			2) AS 'Average Posts by Users';
            
-- -------------------------------------------------------------------------------------------------------------------------------            
            
/*Q6 The Number of Photos posted by most active users */

SELECT
		u.username AS 'username',
	COUNT(p.image_url) AS 'Number of Posts'
FROM
	ig_clone.users u
		JOIN
	ig_clone.photos p ON u.id = p.user_id
    
GROUP BY u.id
ORDER BY 2 DESC
LIMIT 5;
-- -------------------------------------------------------------------------------------------------------------------------------

/* Q7: The total number of posts */

SELECT
	SUM(user_posts.total_posts_per_user) AS 'Total Posts by Users'
FROM
	(SELECT
		u.username, COUNT(p.image_url) AS total_posts_per_user
	FROM 
		ig_clone.users u
	JOIN ig_clone.photos p ON u.id = p.user_id
	group by u.id) AS user_posts;
-- -------------------------------------------------------------------------------------------------------------------------------

/*Q8: The total number of users with posts */

SELECT
	COUNT(DISTINCT (u.id)) AS total_number_of_users_with_posts
FROM
	ig_clone.users u
		JOIN
	ig_clone.photos p ON u.id = p.user_id;
    
-- -------------------------------------------------------------------------------------------------------------------------------

/*Q9: The username with numbers as ending */

SELECT
	id, username
FROM
	ig_clone.users
WHERE
	username REGEXP '[$0-9]';

-- -------------------------------------------------------------------------------------------------------------------------------

/* Q10 The Username with character as ending */

SELECT
	id, username
FROM
	ig_clone.users
WHERE
	username NOT REGEXP '[$0-9]';
    
-- -------------------------------------------------------------------------------------------------------------------------------

/* Q11 The most popular tag names usages */

SELECT
	t.tag_name, COUNT(tag_name) AS seen_used
FROM
	ig_clone.tags t
		JOIN
	ig_clone.photo_tags pt ON t.id = pt.tag_id
GROUP BY t.id
ORDER BY seen_used DESC
LIMIT 10;

-- -------------------------------------------------------------------------------------------------------------------------------

/* Q11: The number of username that start with A */

SELECT 
	count(id)
FROM
	ig_clone.users
WHERE
	username REGEXP '^[A]';
    
-- -------------------------------------------------------------------------------------------------------------------------------

/*Q12  The most popular tag names by usage*/
SELECT
		t.tag_name, COUNT(tag_name) AS seen_used
FROM
	ig_clone.tags t
		JOIN
	ig_clone.photo_tags pt ON t.id = pt.tag_id
GROUP BY t.id
ORDER BY seen_used DESC
LIMIT 10;

-- -------------------------------------------------------------------------------------------------------------------------------

/*Q13 The most popular tag names by likes */

SELECT
	t.tag_name AS 'Tag Name',
    COUNT(l.photo_id) AS 'Number of Likes'
FROM
	ig_clone.photo_tags pt
		JOIN
	ig_clone.likes l ON l.photo_id = pt.photo_id
		JOIN
	ig_clone.tags t ON pt.tag_id = t.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
    
-- -------------------------------------------------------------------------------------------------------------------------------

/* Q14 The users who have liked every single photo on the site*/

SELECT 
	u.id, u.username, COUNT(l.user_id) AS total_likes_by_user
FROM
	ig_clone.users u
		JOIN
	ig_clone.likes l ON u.id = l.user_id
GROUP BY u.id
HAVING total_likes_by_user = (SELECT
		COUNT(*)
	FROM ig_clone.photos);
    
-- -------------------------------------------------------------------------------------------------------------------------------

/* Q15 Total number of users without comments */

SELECT
	COUNT(*) AS total_number_of_users_without_comments
FROM 
	(SELECT u.username,c.comment_text
    FROM
		ig_clone.users u
	LEFT JOIN ig_clone.comments c ON u.id = c.user_id
    GROUP BY u.id, c.comment_text
    HAVING comment_text IS NULL) AS users;
    
-- ----------------------------------------------------------------------------------------------------------------------------------
/* Q16: The Percantage of users who have either never commented on a photo or likes every photo */

    
SELECT 
    tableA.total_A AS 'Number Of Users who never commented',
    (tableA.total_A / (SELECT 
            COUNT(*)
        FROM
            ig_clone.users u)) * 100 AS '%',
    tableB.total_B AS 'Number of Users who likes every photos',
    (tableB.total_B / (SELECT 
            COUNT(*)
        FROM
            ig_clone.users u)) * 100 AS '%'
FROM
    (SELECT 
        COUNT(*) AS total_A
    FROM
        (SELECT 
        u.username, c.comment_text
    FROM
        ig_clone.users u
    LEFT JOIN ig_clone.comments c ON u.id = c.user_id
    GROUP BY u.id , c.comment_text
    HAVING comment_text IS NULL) AS total_number_of_users_without_comments) AS tableA
        JOIN
    (SELECT 
        COUNT(*) AS total_B
    FROM
        (SELECT 
        u.id, u.username, COUNT(u.id) AS total_likes_by_user
    FROM
        ig_clone.users u
    JOIN ig_clone.likes l ON u.id = l.user_id
    GROUP BY u.id , u.username
    HAVING total_likes_by_user = (SELECT 
            COUNT(*)
        FROM
            ig_clone.photos p)) AS total_number_users_likes_every_photos) AS tableB;

-- -------------------------------------------------------------------------------------------------------------------------------

/* Q17 Clean URLS of Photos on the platform */

SELECT
	SUBSTRING(image_url,
			LOCATE('/',image_url)+2,
            LENGTH(image_url)-LOCATE('/', image_url)) AS IMAGE_URL
FROM
	ig_clone.photos;
    
-- -------------------------------------------------------------------------------------------------------------------------------

/* Q18 Average time on platform */
SELECT
	ROUND(AVG(DATEDIFF(CURRENT_TIMESTAMP,created_at)/360),2) as Total_Years_on_Platform
FROM
	ig_clone.users;

-- -------------------------------------------------------------------------------------------------------------------------------
/* Creating a store Procedure */
-- -------------------------------------------------------------------------------------------------------------------------------

/* Q1 Popular hastag list */



DELIMITER //
CREATE PROCEDURE `spPopularTags`()
BEGIN
    SELECT
        t.tag_name, COUNT(tag_name) AS `HashtagCounts`
    FROM
        ig_clone.tags t
            JOIN
        ig_clone.photo_tags pt ON t.id = pt.tag_id
    GROUP BY t.tag_name
    ORDER BY 2 DESC;
END //
DELIMITER ;

CALL `ig_clone`.`spPopularTags`();


	
-- -------------------------------------------------------------------------------------------------------------------------------

/* Q2 Users who have engagged atleast one time on the platform */
DELIMITER //
CREATE PROCEDURE `spEngagedUser`()
BEGIN
SELECT DISTINCT
	username
FROM
	ig_clone.users u
		INNER JOIN
	ig_clone.photos p ON p.user_id = u.id
		INNER JOIN
	ig_clone.likes l ON l.user_id = p.user_id
WHERE
	p.id IS NOT NULL
		OR l.user_id IS NOT NULL;
END //
DELIMITER ;
CALL `ig_clone`.`spEngagedUser`();

-- -------------------------------------------------------------------------------------------------------------------------------
/* Q3 Total number of comments by user on the platform */

DROP PROCEDURE IF EXISTS `spUserCommentsCount`;
DELIMITER //
CREATE PROCEDURE `spUserCommentsCount`()
BEGIN
    SELECT COUNT(*) as 'Total Number of Comments'
    FROM (
        SELECT c.user_id, u.username
        FROM ig_clone.users u
        JOIN ig_clone.comments c ON u.id = c.user_idusers
        WHERE c.comment_text IS NOT NULL
        GROUP BY u.username, c.user_id
    ) as Table1;
END //
DELIMITER ;

CALL `ig_clone`.`spUserCommentsCount`();


-- -------------------------------------------------------------------------------------------------------------------------------
/* Q4 The useername, image posted, tags used and comments made by a specific user */
DELIMITER //
CREATE PROCEDURE `spUserInfo`(IN userid INT(11))
BEGIN
SELECT
	u.id, u.username, p.image_url,c.comment_text,t.tag_name
FROM
	ig_clone.users u
		INNER JOIN
	ig_clone.photos p ON p.user_id = u.id
		INNER JOIN
	ig_clone.comments c ON c.user_id = u.id
		INNER JOIN
	ig_clone.photo_tags pt ON pt.photo_id = p.id
		INNER JOIN
	ig_clone.tags t ON t.id = pt.tag_id
WHERE u.id = userid;

END //
DELIMITER ;

CALL `ig_clone`.`spUserInfo`(2);

