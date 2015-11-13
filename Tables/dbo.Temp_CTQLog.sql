CREATE TABLE [dbo].[Temp_CTQLog]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[EntryID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EqID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LST] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeDiff] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Freq] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Temp_CTQLog] ADD CONSTRAINT [PK_Temp_CTQLog] PRIMARY KEY CLUSTERED  ([RowID]) ON [PRIMARY]
GO
