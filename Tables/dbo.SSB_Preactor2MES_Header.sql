CREATE TABLE [dbo].[SSB_Preactor2MES_Header]
(
[BatchNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BatchDateTime] [datetime] NOT NULL,
[User] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ready] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_Preactor2MES_Header] ADD CONSTRAINT [PK_SSB_Preactor2MES_Header] PRIMARY KEY CLUSTERED  ([BatchNo]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SSB_Preactor2MES_Header] ADD CONSTRAINT [FK_SSB_Preactor2MES_Header_SSB_Preactor2MES_Header] FOREIGN KEY ([BatchNo]) REFERENCES [dbo].[SSB_Preactor2MES_Header] ([BatchNo])
GO
