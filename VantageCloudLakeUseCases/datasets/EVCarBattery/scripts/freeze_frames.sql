CREATE SET TABLE ev_freeze_frames
     (
      id INTEGER NOT NULL, 
      data JSON(2000) CHARACTER SET LATIN, 
PRIMARY KEY ( id ))
;

