CREATE TABLE IF NOT EXISTS leaderboard (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  score INT
);

-- Insert initial data
INSERT INTO leaderboard (name, score) VALUES ('Huba', 42);
INSERT INTO leaderboard (name, score) VALUES ('Bob', 1);
INSERT INTO leaderboard (name, score) VALUES ('Joe', 12);