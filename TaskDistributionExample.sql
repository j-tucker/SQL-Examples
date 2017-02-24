-- Create Schema
DROP TABLE IF EXISTS eTasks
DROP TABLE IF EXISTS eStaff

CREATE TABLE [dbo].[eStaff]
    (
      [StaffID] [INT] IDENTITY(1, 1)
                      NOT NULL ,
      [Name] [VARCHAR](256) NULL ,
      CONSTRAINT [PK_eStaff] PRIMARY KEY CLUSTERED ( [StaffID] ASC )
        WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
               IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
               ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY]
    )
ON  [PRIMARY];

GO

CREATE TABLE [dbo].[eTasks]
    (
      [taskID] [INT] IDENTITY(1, 1)
                     NOT NULL ,
      [staffID] [INT] NOT NULL ,
      [title] [VARCHAR](256) NOT NULL ,
      [description] [VARCHAR](MAX) NULL ,
      [createDate] [DATETIME] NOT NULL ,
      CONSTRAINT [PK_eTasks] PRIMARY KEY CLUSTERED ( [taskID] ASC )
        WITH ( PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF,
               IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON,
               ALLOW_PAGE_LOCKS = ON ) ON [PRIMARY]
    );


GO

SET ANSI_PADDING OFF;
GO

ALTER TABLE [dbo].[eTasks]  WITH CHECK ADD  CONSTRAINT [FK_eTasks_eStaff] FOREIGN KEY([staffID])
REFERENCES [dbo].[eStaff] ([StaffID]);
GO

ALTER TABLE [dbo].[eTasks] CHECK CONSTRAINT [FK_eTasks_eStaff];
GO


-- Populate Test Data

INSERT  INTO eStaff
        ( Name )
VALUES  ( 'Abigail' ),
        ( 'Beatrice' ),
        ( 'Cindy' ),
        ( 'Doris' );

GO

WITH    Nbrs_3 ( n )
          AS ( SELECT   1
               UNION
               SELECT   0
             ),
        Nbrs_2 ( n )
          AS ( SELECT   1
               FROM     Nbrs_3 n1
                        CROSS JOIN Nbrs_3 n2
             ),
        Nbrs_1 ( n )
          AS ( SELECT   1
               FROM     Nbrs_2 n1
                        CROSS JOIN Nbrs_2 n2
             ),
        Nbrs_0 ( n )
          AS ( SELECT   1
               FROM     Nbrs_1 n1
                        CROSS JOIN Nbrs_1 n2
             ),
        Nbrs ( n )
          AS ( SELECT   1
               FROM     Nbrs_0 n1
                        CROSS JOIN Nbrs_0 n2
             )
    INSERT  INTO eTasks
            ( staffID ,
              title ,
              createDate
            )
            SELECT  ( SELECT TOP 1
                                StaffID
                      FROM      eStaff
                    ) ,
                    'Task ' + CAST(n AS VARCHAR(50)) ,
                    GETDATE() - n
            FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY n )
                      FROM      Nbrs
                    ) D ( n )
            WHERE   n <= 500; 

GO

SELECT  *
FROM    eStaff;
SELECT  *
FROM    eTasks;

GO

DECLARE @totalStaff INT

SELECT  @totalStaff = COUNT(1)
FROM    eStaff


-- Show aggregate results before
	SELECT  s.Name ,
			COUNT(1) [Number of Tasks] ,
			MIN(createdate) Min ,
			MAX(createdate) Max
	FROM    eTasks t
			JOIN estaff s ON s.staffid = t.staffid
	GROUP BY s.name

-- Allocate staff to tasks...

	UPDATE  t
	SET     StaffID = s.StaffID
	FROM    ( SELECT    ( ROW_NUMBER() OVER ( ORDER BY t.createdate )
						  % @totalStaff ) + 1 StaffKey ,
						*
			  FROM      eTasks t
			) t
			CROSS APPLY ( SELECT    *
						  FROM      ( SELECT    ROW_NUMBER() OVER ( ORDER BY s.staffid ) StaffKey ,
												*
									  FROM      eStaff s
									) s
						  WHERE     t.StaffKey = s.StaffKey
						) s

-- Show aggregate results after
	SELECT  s.Name ,
			COUNT(1) [Number of Tasks] ,
			MIN(createdate) Min ,
			MAX(createdate) Max
	FROM    eTasks t
			JOIN estaff s ON s.staffid = t.staffid
	GROUP BY s.name