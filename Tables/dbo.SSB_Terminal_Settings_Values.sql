CREATE TABLE [dbo].[SSB_Terminal_Settings_Values]
(
[pk] [int] NOT NULL IDENTITY(1, 1),
[value] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Terminal_pk] [int] NOT NULL,
[Terminal_Settings_pk] [int] NOT NULL,
[LastUpdated] [datetime] NULL CONSTRAINT [DF_SSB_Terminal_Settings_Values_LastUpdated] DEFAULT (getutcdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_Terminal_Settings_Values] ADD CONSTRAINT [PK_SSB_Terminal_Settigs_Values] PRIMARY KEY CLUSTERED  ([pk]) ON [PRIMARY]
GO
