SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SSB_RFIDAnalysis]
		@StartDate		datetime
AS

DECLARE	@tblTempEntry AS Table	(	RowId			int	IDENTITY	,
									EntryID			nvarchar(100)	,
									[TimeStamp]		datetime		,
									[StackTrace]	nvarchar(100)	)
								

DECLARE	@tblEntry AS Table	(	RowId			int	IDENTITY	,
								EntryID			nvarchar(100)	,
								MU				nvarchar(100)	,
								BA				nvarchar(100)	,
								PA				nvarchar(100)	,
								INS				nvarchar(100)	,
								BoxPKG			nvarchar(100)	)


DECLARE @intStart			int				,
		@intEnd				int				,
		@MUTimestamp		nvarchar(100)	,
		@BoxPKGTimestamp	nvarchar(100)	,
		@BATimestamp		nvarchar(100)	,
		@INSTimestamp		nvarchar(100)	,
		@PATimestamp		nvarchar(100)	,	
		@intDataCount		int				,	
		@SelEntryID			nvarchar(100)	


/* SELECT @StartDate='2015-04-10 00:00:00' */

INSERT INTO @tblTempEntry ( [EntryID],[TimeStamp],[StackTrace])
	SELECT [EntryID],[TimeStamp],[StackTrace]
	 FROM [logbook].[dbo].[ArchCSCustomLogSerta/SertaLog]
	 where ProcessId = 'RFID Manager' AND
		   EntryID like '100%' AND
		   TimeStamp > =@StartDate
		   
INSERT INTO @tblEntry (EntryID)
	SELECT DISTINCT([EntryID])
	 FROM @tblTempEntry
	 where EntryID like '100%' AND
		   TimeStamp > =@StartDate


SELECT @intStart=MIN(RowID),
	   @intEnd  = MAX(RowID)
FROM @tblEntry

WHILE @intStart<=@intEnd
	BEGIN
		SELECT @SelEntryID	=EntryID
		FROM @tblEntry
		WHERE RowId=@intStart
		
		/* MU */
		SELECT @intDataCount=COUNT([TimeStamp])
		FROM @tblTempEntry
		where EntryID =@SelEntryID and
			  [StackTrace]='MU'	
		IF  @intDataCount >0
			BEGIN
				SELECT @MUTimestamp=CONVERT(nvarchar(100),MIN([TimeStamp]))
				FROM @tblTempEntry
				where EntryID =@SelEntryID and
					  [StackTrace]='MU'
			END
		ELSE
			BEGIN
				SELECT @MUTimestamp='ERROR'
			END
	
		/* BORDER_ASSEMBLY */
		SELECT @intDataCount=COUNT([TimeStamp])
		FROM @tblTempEntry
		where EntryID =@SelEntryID and
			  [StackTrace]='BORDER_ASSEMBLY'	
		IF  @intDataCount >0
			BEGIN
				SELECT @BATimestamp=CONVERT(nvarchar(100),MIN([TimeStamp]))
				FROM @tblTempEntry
				where EntryID =@SelEntryID and
					  [StackTrace]='BORDER_ASSEMBLY'
			END
		ELSE
			BEGIN
				SELECT @BATimestamp='ERROR'
			END
	
		/* PANEL_ASSEMBLY */
		SELECT @intDataCount=COUNT([TimeStamp])
		FROM @tblTempEntry
		where EntryID =@SelEntryID and
			  [StackTrace]='PANEL_ASSEMBLY'	
		IF  @intDataCount >0
			BEGIN
				SELECT @PATimestamp=CONVERT(nvarchar(100),MIN([TimeStamp]))
				FROM @tblTempEntry
				where EntryID =@SelEntryID and
					  [StackTrace]='PANEL_ASSEMBLY'
			END
		ELSE
			BEGIN
				SELECT @PATimestamp='ERROR'
			END
		
		/* INSPECTION */
		SELECT @intDataCount=COUNT([TimeStamp])
		FROM @tblTempEntry
		where EntryID =@SelEntryID and
			  [StackTrace]='INSPECTION'	
		IF  @intDataCount >0
			BEGIN
				SELECT @INSTimestamp=CONVERT(nvarchar(100),MIN([TimeStamp]))
				FROM @tblTempEntry
				where EntryID =@SelEntryID and
					  [StackTrace]='INSPECTION'
			END
		ELSE
			BEGIN
				SELECT @INSTimestamp='ERROR'
			END
		
		/* BOXPKG */
		SELECT @intDataCount=COUNT([TimeStamp])
		FROM @tblTempEntry
		where EntryID =@SelEntryID and
			  [StackTrace]='BOXPKG'	
		IF  @intDataCount >0
			BEGIN
				SELECT @BoxPKGTimestamp=CONVERT(nvarchar(100),MIN([TimeStamp]))
				FROM @tblTempEntry
				where EntryID =@SelEntryID and
					  [StackTrace]='BOXPKG'
			END
		ELSE
			BEGIN
				SELECT @BoxPKGTimestamp='ERROR'
			END
			
		UPDATE @tblEntry
			SET MU=@MUTimestamp,
			    BA=@BATimestamp,
			    PA=@PATimestamp,
			    BoxPKG=@BoxPKGTimestamp,
			    INS	=@INSTimestamp
			WHERE RowId=@intStart	
	SELECT @intStart=@intStart + 1
   END
   
   SELECT * FROM @tblEntry
	ORDER BY MU,EntryID
GO
