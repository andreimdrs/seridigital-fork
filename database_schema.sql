PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- =============================
-- Core tables
-- =============================

-- Users
CREATE TABLE IF NOT EXISTS tb_users (
  usr_id INTEGER PRIMARY KEY AUTOINCREMENT,
  usr_name VARCHAR(255) NOT NULL,
  usr_email VARCHAR(255) NOT NULL UNIQUE,
  usr_password VARCHAR(255) NOT NULL,
  usr_profile_picture VARCHAR(255),
  usr_bio TEXT,
  is_admin BOOLEAN NOT NULL DEFAULT 0,
  usr_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE IF NOT EXISTS tb_categories (
  cat_id INTEGER PRIMARY KEY AUTOINCREMENT,
  cat_name VARCHAR(255) NOT NULL
);

-- Contents (Works)
CREATE TABLE IF NOT EXISTS tb_contents (
  cnt_id INTEGER PRIMARY KEY AUTOINCREMENT,
  cnt_title VARCHAR(255) NOT NULL,
  cnt_description TEXT,
  cnt_type VARCHAR(50) NOT NULL, -- 'livro' ou 'manifesto'
  cnt_url VARCHAR(255),
  cnt_thumbnail VARCHAR(255),
  cnt_file_path VARCHAR(500),
  cnt_file_type VARCHAR(10),
  cnt_release_date DATE,
  cnt_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Communities
CREATE TABLE IF NOT EXISTS tb_communities (
  com_id INTEGER PRIMARY KEY AUTOINCREMENT,
  com_owner_id INTEGER NOT NULL,
  com_name VARCHAR(255) NOT NULL,
  com_description TEXT,
  com_status VARCHAR(20) NOT NULL DEFAULT 'active',
  com_is_filtered BOOLEAN NOT NULL DEFAULT 0,
  com_filter_reason VARCHAR(255),
  com_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (com_owner_id) REFERENCES tb_users(usr_id)
);

-- =============================
-- Community interactions
-- =============================

-- Community posts
CREATE TABLE IF NOT EXISTS tb_community_posts (
  post_id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_author_id INTEGER NOT NULL,
  post_community_id INTEGER NOT NULL,
  post_content TEXT NOT NULL,
  post_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_author_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (post_community_id) REFERENCES tb_communities(com_id)
);

-- Likes on community posts
CREATE TABLE IF NOT EXISTS tb_community_post_likes (
  cpl_id INTEGER PRIMARY KEY AUTOINCREMENT,
  cpl_user_id INTEGER NOT NULL,
  cpl_post_id INTEGER NOT NULL,
  cpl_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cpl_user_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (cpl_post_id) REFERENCES tb_community_posts(post_id),
  UNIQUE (cpl_user_id, cpl_post_id)
);

-- Comments on community posts
CREATE TABLE IF NOT EXISTS tb_community_post_comments (
  cpc_id INTEGER PRIMARY KEY AUTOINCREMENT,
  cpc_user_id INTEGER NOT NULL,
  cpc_post_id INTEGER NOT NULL,
  cpc_text TEXT NOT NULL,
  cpc_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cpc_user_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (cpc_post_id) REFERENCES tb_community_posts(post_id)
);

-- Community blocks
CREATE TABLE IF NOT EXISTS tb_community_blocks (
  blk_id INTEGER PRIMARY KEY AUTOINCREMENT,
  blk_user_id INTEGER NOT NULL,
  blk_community_id INTEGER NOT NULL,
  blk_reason VARCHAR(255),
  blk_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (blk_user_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (blk_community_id) REFERENCES tb_communities(com_id),
  UNIQUE (blk_user_id, blk_community_id)
);

-- =============================
-- Content interactions
-- =============================

-- Ratings on contents
CREATE TABLE IF NOT EXISTS tb_ratings (
  rat_id INTEGER PRIMARY KEY AUTOINCREMENT,
  rat_user_id INTEGER NOT NULL,
  rat_content_id INTEGER NOT NULL,
  rat_rating INTEGER NOT NULL CHECK (rat_rating >= 1 AND rat_rating <= 5),
  rat_review TEXT,
  rat_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rat_user_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (rat_content_id) REFERENCES tb_contents(cnt_id),
  UNIQUE (rat_user_id, rat_content_id)
);

-- Comments on contents (optional feature)
CREATE TABLE IF NOT EXISTS tb_comments (
  cmt_id INTEGER PRIMARY KEY AUTOINCREMENT,
  cmt_user_id INTEGER NOT NULL,
  cmt_content_id INTEGER NOT NULL,
  cmt_text TEXT NOT NULL,
  cmt_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cmt_user_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (cmt_content_id) REFERENCES tb_contents(cnt_id)
);

-- Likes on contents (optional feature)
CREATE TABLE IF NOT EXISTS tb_likes (
  lik_id INTEGER PRIMARY KEY AUTOINCREMENT,
  lik_user_id INTEGER NOT NULL,
  lik_content_id INTEGER NOT NULL,
  lik_created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (lik_user_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (lik_content_id) REFERENCES tb_contents(cnt_id),
  UNIQUE (lik_user_id, lik_content_id)
);

-- Content categories mapping
CREATE TABLE IF NOT EXISTS tb_content_categories (
  cct_content_id INTEGER NOT NULL,
  cct_category_id INTEGER NOT NULL,
  PRIMARY KEY (cct_content_id, cct_category_id),
  FOREIGN KEY (cct_content_id) REFERENCES tb_contents(cnt_id),
  FOREIGN KEY (cct_category_id) REFERENCES tb_categories(cat_id)
);

-- =============================
-- Social features
-- =============================

-- Followers mapping (user to user)
CREATE TABLE IF NOT EXISTS tb_followers (
  fol_follower_id INTEGER NOT NULL,
  fol_followed_id INTEGER NOT NULL,
  fol_followed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (fol_follower_id, fol_followed_id),
  FOREIGN KEY (fol_follower_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (fol_followed_id) REFERENCES tb_users(usr_id)
);

-- Private messages
CREATE TABLE IF NOT EXISTS tb_private_messages (
  msg_id INTEGER PRIMARY KEY AUTOINCREMENT,
  msg_sender_id INTEGER NOT NULL,
  msg_receiver_id INTEGER NOT NULL,
  msg_text TEXT NOT NULL,
  msg_sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  msg_is_read BOOLEAN NOT NULL DEFAULT 0,
  FOREIGN KEY (msg_sender_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (msg_receiver_id) REFERENCES tb_users(usr_id)
);

-- Watch history (optional)
CREATE TABLE IF NOT EXISTS tb_watch_history (
  wht_id INTEGER PRIMARY KEY AUTOINCREMENT,
  wht_user_id INTEGER NOT NULL,
  wht_content_id INTEGER NOT NULL,
  wht_last_watched DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  wht_progress REAL NOT NULL,
  FOREIGN KEY (wht_user_id) REFERENCES tb_users(usr_id),
  FOREIGN KEY (wht_content_id) REFERENCES tb_contents(cnt_id)
);

-- =============================
-- Indexes
-- =============================

-- Users
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuario_email ON tb_users (usr_email);

-- Contents
CREATE INDEX IF NOT EXISTS idx_content_type ON tb_contents (cnt_type);
CREATE INDEX IF NOT EXISTS idx_content_created ON tb_contents (cnt_created_at);
CREATE INDEX IF NOT EXISTS idx_content_title ON tb_contents (cnt_title);

-- Communities
CREATE INDEX IF NOT EXISTS idx_community_owner ON tb_communities (com_owner_id);
CREATE INDEX IF NOT EXISTS idx_community_status ON tb_communities (com_status);

-- Community posts
CREATE INDEX IF NOT EXISTS idx_post_author ON tb_community_posts (post_author_id);
CREATE INDEX IF NOT EXISTS idx_post_community ON tb_community_posts (post_community_id);
CREATE INDEX IF NOT EXISTS idx_post_created ON tb_community_posts (post_created_at);

-- Ratings
CREATE INDEX IF NOT EXISTS idx_rating_content ON tb_ratings (rat_content_id);
CREATE INDEX IF NOT EXISTS idx_rating_user ON tb_ratings (rat_user_id);
CREATE INDEX IF NOT EXISTS idx_rating_created ON tb_ratings (rat_created_at);

-- Community comments/likes
CREATE INDEX IF NOT EXISTS idx_comment_post ON tb_community_post_comments (cpc_post_id);
CREATE INDEX IF NOT EXISTS idx_comment_user ON tb_community_post_comments (cpc_user_id);
CREATE INDEX IF NOT EXISTS idx_like_post ON tb_community_post_likes (cpl_post_id);
CREATE INDEX IF NOT EXISTS idx_like_created ON tb_community_post_likes (cpl_created_at);

COMMIT;