SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[jd_temp_insert_wi] @folder_pk int, @id nvarchar(50), @dir nvarchar(1000), @equipment_id nvarchar(50), @required bit
as
insert into SSB..wi_qual_test( equipment_class_id, qualification_test_id, folder_pk, expiration_seconds, can_acknowledge, /*default_instruction,*/ requires_pass ) values(@equipment_id, @id,@folder_pk, 60*60*24*30, @required, @required )
if (select count(*) from SitMesDB..[hrm_qual_test_spec] where id=@id)>0
begin
	declare @spec_pk int 
	set @spec_pk = (select hrm_qual_test_spec_pk from SitMesDB..[hrm_qual_test_spec] where id=@id)
	delete from SitMesDB..hrm_pers_qual_test_result_desc where hrm_pers_qual_test_result_pk in ( select hrm_pers_qual_test_result_pk from SitMesDB..hrm_pers_qual_test_result where hrm_qual_test_spec_pk=@spec_pk)
	delete from SitMesDB..hrm_pers_qual_test_result where hrm_qual_test_spec_pk=@spec_pk
	delete from SitMesDB..[hrm_qual_test_spec] where id=@id
end
INSERT INTO SitMesDB..[hrm_qual_test_spec]([id],[version],[doc_hyperlink],[last_date],[last_user],[last_prog],[bias],[label],[RowUpdated],[resource_name],[resource_id]) VALUES( @id, '1.00', @dir, getutcdate(), 'duffyj', 'sql', 0, @id, getutcdate(), null, null )
GO
