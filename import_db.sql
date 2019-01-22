DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;


PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER,

  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  user_id INTEGER,
  questions_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users (id),
  FOREIGN KEY (questions_id) REFERENCES questions (id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions (id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies (id),
  FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_like_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_like_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Frank', 'Underwood'),
  ('Claire', 'Underwood');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Deleting evidence', 'How do I go about covering up my crimes?', 
  (SELECT
    id 
  FROM
    users 
  WHERE 
    fname = 'Frank'
  )),
  ('Covering President', 'How do I hide presidential wrongdoings?', (
    SELECT
      id
    FROM 
      users
    WHERE
      fname = 'Claire'
  ));

  INSERT INTO 
    question_follows(user_id, questions_id)
  VALUES
    ((SELECT
      id 
    FROM 
      users
    LIMIT 1), 
    
    (SELECT
      id 
    FROM
      questions 
    LIMIT 1 OFFSET 1)), 
    
    ((SELECT
      id 
    FROM 
      users
    LIMIT 1 OFFSET 1), 
    
    (SELECT
      id 
    FROM
      questions 
    LIMIT 1));

  INSERT INTO 
    replies(question_id, parent_reply_id, user_id, body)
  VALUES
    ((SELECT
        id 
      FROM
        questions 
      LIMIT 1 OFFSET 1),
      NULL,
      (SELECT
        id 
      FROM 
        users
      LIMIT 1), 'You are very corrupt.'),
    ((SELECT
      id 
    FROM
      questions 
    LIMIT 1),
    NULL,
    (SELECT
      id 
    FROM 
      users
    LIMIT 1), 'Underwood 2020!');

  INSERT INTO
    question_likes(question_id, user_like_id)
  VALUES
    ((SELECT
      id 
    FROM 
      users
    LIMIT 1), 
    
    (SELECT
      id 
    FROM
      questions 
    LIMIT 1 OFFSET 1)), 
    
    ((SELECT
      id 
    FROM 
      users
    LIMIT 1 OFFSET 1), 
    
    (SELECT
      id 
    FROM
      questions 
    LIMIT 1));

    

