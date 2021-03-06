USE [giga_test]
GO
/****** Object:  StoredProcedure [dbo].[ydbc_dr_multiuse]    Script Date: 8/23/2016 4:30:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[ydbc_dr_multiuse]
@user_id varchar(100)
,@record_type varchar(100)
,@record_id varchar(8000)
,@field01_value varchar(8000)
,@field02_value varchar(8000)
,@field03_value varchar(8000)
,@field04_value varchar(8000)
,@field05_value varchar(8000)
,@field06_value varchar(8000)
,@field07_value varchar(8000)
,@field08_value varchar(8000)
,@field09_value varchar(8000)
,@field10_value varchar(8000)
,@field11_value varchar(8000)
,@field12_value varchar(8000)
,@field13_value varchar(8000)
,@field14_value varchar(8000)
,@field15_value varchar(8000)
,@field16_value varchar(8000)
,@field17_value varchar(8000)
,@field18_value varchar(8000)
,@field19_value varchar(8000)
,@field20_value varchar(8000)
,@record_id_out varchar(8000) output
,@field01_value_out varchar(8000) output
,@field02_value_out varchar(8000) output
,@field03_value_out varchar(8000) output
,@field04_value_out varchar(8000) output
,@field05_value_out varchar(8000) output
,@field06_value_out varchar(8000) output
,@field07_value_out varchar(8000) output
,@field08_value_out varchar(8000) output
,@field09_value_out varchar(8000) output
,@field10_value_out varchar(8000) output
,@field11_value_out varchar(8000) output
,@field12_value_out varchar(8000) output
,@field13_value_out varchar(8000) output
,@field14_value_out varchar(8000) output
,@field15_value_out varchar(8000) output
,@field16_value_out varchar(8000) output
,@field17_value_out varchar(8000) output
,@field18_value_out varchar(8000) output
,@field19_value_out varchar(8000) output
,@field20_value_out varchar(8000) output
,@org_value varchar(8000)
,@msgbox_title varchar(100) output
,@results varchar(8000) output
,@status int output
as
/*
Multiuse Rule Status Options
0 - Gives a failure message and drops the user back into the field they started
1 - Success for the user
2 - Gives a Yes or No Pop-up Box asking the user to continue
3 - Gives an Informational Pop-up Box with OK Button
4 - Pops up a dialog box with an Option Form
5 - Pops up a box to send an email - can prepopulate info in box
6 - Validates data entered
7 - Execute a remote command/program
8 - Pop-up Box asking Yes/No to Execute a remote command/program
9 - Pop-up with Password Needed to Continue - Supervisor Permission
10 - Update Multiple Field Values
11 - Create files & Execute on of the files
12 - Update Multiple Field Values with prompts
13 - Show grid for display use only
14 - Check for Duplicates
*/

/*
 * Pick Ticket Report Rule
 */

if @record_type = 'PrintPTOpen'
begin
	select
		@status = 10,
		@field01_value_out = 'Both'
end

if @record_type = 'printwhitestart'
	begin
		select
			@status = 10,
			/* beg_order_date */
			@field01_value_out = convert(varchar, (select min(giga_open_orders_view_w_cust_and_supplier_info.order_date) from giga_open_orders_view_w_cust_and_supplier_info), 101),
			/* beg_required_date */
			@field02_value_out = convert(varchar, (select min(giga_open_production_order_info.required_date) from giga_open_production_order_info), 101),
			/* dt_beg_date2 */
			@field03_value_out = convert(varchar, getdate() + 15, 101),
			/* Include Scheduled Releases */
			@field04_value_out = 'Y',
			/* location_id */
			@field05_value_out = '1',
			/* no_licensed_mode_flag */
			@field06_value_out = 'Y',
			/* period_m */
			@field07_value_out = '15',
			/* route_or_zip */
			@field08_value_out = 'Zip Code',
			/* str_beg_account */
			@field09_value_out = '',
			/* str_end_account */
			@field10_value_out = 'Y'
	end

if @record_type = 'printwhiteend'
	begin
		select
			@status = 10,
			/* dt_end_date2 */
			@field01_value_out = convert(varchar, (select max(giga_open_orders_view_w_cust_and_supplier_info.cust_req_date) from giga_open_orders_view_w_cust_and_supplier_info), 101),
			/* end_order_date */
			@field02_value_out = convert(varchar, (select max(giga_open_production_order_info.required_date) from giga_open_production_order_info), 101),
			/* end_required_date */
			@field03_value_out = convert(varchar, (select max(giga_open_orders_view_w_cust_and_supplier_info.order_date) from giga_open_orders_view_w_cust_and_supplier_info), 101)
	end

if @record_type = 'printgreenstart'
	begin
		select
			@status = 10,
			/* beg_order_date */
			@field01_value_out = convert(varchar, (select min(giga_open_orders_view_w_cust_and_supplier_info.order_date) from giga_open_orders_view_w_cust_and_supplier_info), 101),
			/* beg_required_date */
			@field02_value_out = convert(varchar, '00/00/00 00:00:00', 101),
			/* dt_beg_date2 */
			@field03_value_out = convert(varchar, (select min(giga_open_orders_view_w_cust_and_supplier_info.cust_req_date) from giga_open_orders_view_w_cust_and_supplier_info), 101),
			/* include_scheduled_releases */
			@field04_value_out = 'Y',
			/* location_id */
			@field05_value_out = '1',
			/* no_licensed_mode_flag */
			@field06_value_out = 'Y',
			/* period_m */
			@field07_value_out = '15',
			/* route_or_zip */
			@field08_value_out = 'Zip Code',
			/* str_beg_account */
			@field09_value_out = '',
			/* str_end_account */
			@field10_value_out = 'Y',
			/* will_call */
			@field11_value_out = 'Y'
	end

if @record_type = 'printgreenend'
	begin
		select
			@status = 10,
			/* dt_end_date2 */
			@field01_value_out = convert(varchar, getdate() + 14, 101),
			/* end_order_date */
			@field02_value_out = convert(varchar, (select max(giga_open_orders_view_w_cust_and_supplier_info.order_date) from giga_open_orders_view_w_cust_and_supplier_info), 101),
			/* end_required_date */
			@field03_value_out = convert(varchar, '00/00/00 00:00:00', 101)
	end

if @record_type = 'printzhotstart'
	begin
		select
			@status = 10,
			/* beg_order_date */
			@field01_value_out = convert(varchar, (select min(giga_open_orders_view_w_cust_and_supplier_info.order_date) from giga_open_orders_view_w_cust_and_supplier_info), 101),
			/* dt_beg_date2 */
			@field02_value_out = convert(varchar, (select min(giga_open_orders_view_w_cust_and_supplier_info.cust_req_date) from giga_open_orders_view_w_cust_and_supplier_info), 101),
			/* include_scheduled_releases */
			@field03_value_out = 'Y',
			/* location_id */
			@field04_value_out = '1',
			/* no_licensed_mode_flag */
			@field05_value_out = 'Y',
			/* period_m */
			@field06_value_out = '15',
			/* route_or_zip */
			@field07_value_out = 'Zip Code',
			/* str_beg_account */
			@field08_value_out = 'Z',
			/* str_end_account */
			@field09_value_out = 'ZZZZZ',
			/* will_call */
			@field10_value_out = 'Y',
			/* beg_required_date */
			@field11_value_out = convert(varchar, '00/00/00 00:00:00', 101)
	end

if @record_type = 'printzhotend'
	begin
		select
			@status = 10,
			/* dt_end_date2 */
			@field01_value_out = convert(varchar, (select max(giga_open_orders_view_w_cust_and_supplier_info.cust_req_date) from giga_open_orders_view_w_cust_and_supplier_info), 101),
			/* end_order_date */
			@field02_value_out = convert(varchar, (select max(giga_open_orders_view_w_cust_and_supplier_info.order_date) from giga_open_orders_view_w_cust_and_supplier_info), 101),
			/* end_required_date */
			@field03_value_out = convert(varchar, '00/00/00 00:00:00', 101),
			/* str_end_account */
			@field04_value_out = 'ZZZZZ'
	end

if @record_type = 'printhawkstart'
	begin
		select
			@status = 10,
			/* beg_order_date */
			@field01_value_out = convert(varchar, (select min(giga_open_orders_view_w_cust_and_supplier_info.order_date) from giga_open_orders_view_w_cust_and_supplier_info where giga_open_orders_view_w_cust_and_supplier_info.company_id = 'HAWK'), 101),
			/* company_id */
			@field02_value_out = 'HAWK',
			/* dt_beg_date2 */
			@field03_value_out = convert(varchar, (select min(giga_open_orders_view_w_cust_and_supplier_info.cust_req_date) from giga_open_orders_view_w_cust_and_supplier_info where giga_open_orders_view_w_cust_and_supplier_info.company_id = 'HAWK'), 101),
			/* include_scheduled_releases */
			@field04_value_out = 'Y',
			/* location_id */
			@field05_value_out = '2',
			/* no_licensed_mode_flag */
			@field06_value_out = 'Y',
			/* period_m */
			@field07_value_out = '15',
			/* route_or_zip */
			@field08_value_out = 'Zip Code',
			/* str_beg_account */
			@field09_value_out = 'Z',
			/* str_end_account */
			@field10_value_out = 'ZZZZZ',
			/* will_call */
			@field11_value_out = 'Y',
			/* beg_required_date */
			@field12_value_out = convert(varchar, (select min(giga_open_production_order_info.required_date) from giga_open_production_order_info where giga_open_production_order_info.company_id = 'HAWK'), 101)
	end

if @record_type = 'printhawkend'
	begin
		select
			@status = 10,
			/* dt_end_date2 */
			@field01_value_out = convert(varchar, (select max(giga_open_orders_view_w_cust_and_supplier_info.cust_req_date) from giga_open_orders_view_w_cust_and_supplier_info where giga_open_orders_view_w_cust_and_supplier_info.company_id = 'HAWK'), 101),
			/* end_order_date */
			@field02_value_out = convert(varchar, (select dateadd(dd, 7, max(giga_open_orders_view_w_cust_and_supplier_info.order_date)) from giga_open_orders_view_w_cust_and_supplier_info where giga_open_orders_view_w_cust_and_supplier_info.company_id = 'HAWK'), 101),
			/* end_required_date */
			@field03_value_out = convert(varchar, (select max(giga_open_production_order_info.required_date) from giga_open_production_order_info where giga_open_production_order_info.company_id = 'HAWK'), 101),
			/* str_end_account */
			@field04_value_out = 'ZZZZZ'
	end

/* End of Pick Ticket Report Rule */

/*
	Begin Order Entry Rule
*/

--Triggered when the ORIGINAL "Email" is clicked under Order Acknowledgements on the Print Options tab.
if @record_type = 'email_ack_options'
	begin
		select
			@status = 10,
			--ufc_p21soc_email_oa
			@field02_value_out = @field01_value --> email_orderack
	end

--Triggered when the NEW "Email" is clicked "on" under the Order tab.
if @record_type = 'email_ack_order'
	begin
		select
			@status = 10,
			--email_order_ack
			@field02_value_out = @field01_value --> ufc_p21soc_email_oa
	end

--Triggered when the ORIGINAL "Print" is clicked "on" under Order Acknowledgements on the Order tab.
if @record_type = 'print_ack_options'
	begin
		select
			@status = 10,
			--ufc_p21soc_print_oa
			@field02_value_out = @field01_value --> print_orderack
	end

--Triggered when the NEW "Print" is clicked under Order Acknowledgements on the Print Options tab.
if @record_type = 'print_ack_order'
	begin
		select
			@status = 10,
			--print_order_ack
			@field02_value_out = @field01_value --> ufc_p21soc_print_oa
	end

--Triggered when the ORIGINAL "Fax" is clicked under Order Acknowledgements on the Order tab.
if @record_type = 'fax_ack_options'
	begin
		select
			@status = 10,
			--ufc_p21soc_fax_oa
			@field02_value_out = @field01_value --> fax_orderack
	end

--Triggered when the NEW "Fax" is clicked under Order Acknowledgements on the Print Options tab.
if @record_type = 'fax_ack_order'
	begin
		select
			@status = 10,
			--fax_orderack
			@field02_value_out = @field01_value --> ufc_p21soc_faxoa
	end

/* End Order Entry Rule */

-- Turn Mandatory checkbox off ---------
-- Applied to Freight Code under oe_hdr
if @record_type = 'disablemandatory'
begin
	select
		@status = 10
		,@field01_value_out = 'N'
end
----------------------------------------

--copy shipping info to screen only column in order entry


if @record_type = 'oechangestconvert' and len(@org_value) > 0
begin
	select
		@status = 10
		--ufc_p21soc_soc_delivery_instructions_copy value = delivery_instructions value
		,@field02_value_out = @field01_value
		--ufc_p21soc_soc_freightcode value = freight_cd value
		,@field04_value_out = @field03_value
end

if @record_type = 'oechangestvalid' and len(@org_value) > 0
begin
	select
		@status = 10
		--delivery_instructions value = ufc_p21soc_soc_delivery_instructions_copy
		,@field02_value_out = @field01_value
		,@field01_value_out = ''
		--freight_cd value = ufc_p21soc_soc_freightcode value
		,@field03_value_out = @field04_value
		--set soc to empty
		,@field04_value_out = ''
end

if @record_type = 'outlook_email_template'
begin
	/*
		FLD01 - template file full path
		FLD02 - TO (may not be required with template file - depends on template)
		FLD03 - CC (may not be required with template file - depends on template)
		FLD04 - BCC (may not be required with template file - depends on template)
		FLD05 - Subject (may not be required with template file - depends on template)
		FLD06 - Body (may not be required with template file - depends on template)
		FLD07 - HTML/TEXT - REQUIRED - Use either option depending on what is sent in Body (will need to know how template is formatted OR Body msg used above)
		FLD08 - Attachment
		FLD09 - Attachment
		FLD10 - Attachment
		FLD11 to FLD19 ODD numbers - template/body variables to replace
		FLD12 to FLD20 EVEN numbers - template/body variable values used in replace
	*/

	select
		@field03_value = substring(@field02_value, charindex('M&N:  ', @field02_value) + 6, 17)  --REQN
		,@field04_value = substring(@field02_value, charindex('FMS CASE ', @field02_value) + 9, 3) --FMS

	select 
		@status = 15
		,@field01_value_out = 'S:\Matt''s Team Stuff\FMS address request.oft'
		,@field02_value_out = ''
		,@field03_value_out = ''
		,@field04_value_out = ''
		,@field05_value_out = ''
		,@field06_value_out = ''
		,@field07_value_out = 'HTML'
		,@field08_value_out = ''
		,@field09_value_out = ''
		,@field10_value_out = ''
		,@field11_value_out = '%PO%'
		,@field12_value_out = @field01_value
		,@field13_value_out = '%REQN%'
		,@field14_value_out = @field03_value
		,@field15_value_out = '%FMS%'
		,@field16_value_out = @field04_value
		,@field17_value_out = '%ORD#%'
		,@field18_value_out = @field05_value	
		,@field19_value_out = ''
		,@field20_value_out = ''
end

if @status in (6,7,8,10,12)
begin
	select
		@record_id_out = coalesce(@record_id_out, @record_id)
		,@field01_value_out = coalesce(@field01_value_out, @field01_value)
		,@field02_value_out = coalesce(@field02_value_out, @field02_value)
		,@field03_value_out = coalesce(@field03_value_out, @field03_value)
		,@field04_value_out = coalesce(@field04_value_out, @field04_value)
		,@field05_value_out = coalesce(@field05_value_out, @field05_value)
		,@field06_value_out = coalesce(@field06_value_out, @field06_value)
		,@field07_value_out = coalesce(@field07_value_out, @field07_value)
		,@field08_value_out = coalesce(@field08_value_out, @field08_value)
		,@field09_value_out = coalesce(@field09_value_out, @field09_value)
		,@field10_value_out = coalesce(@field10_value_out, @field10_value)
		,@field11_value_out = coalesce(@field11_value_out, @field11_value)
		,@field12_value_out = coalesce(@field12_value_out, @field12_value)
		,@field13_value_out = coalesce(@field13_value_out, @field13_value)
		,@field14_value_out = coalesce(@field14_value_out, @field14_value)
		,@field15_value_out = coalesce(@field15_value_out, @field15_value)
		,@field16_value_out = coalesce(@field16_value_out, @field16_value)
		,@field17_value_out = coalesce(@field17_value_out, @field17_value)
		,@field18_value_out = coalesce(@field18_value_out, @field18_value)
		,@field19_value_out = coalesce(@field19_value_out, @field19_value)
		,@field20_value_out = coalesce(@field20_value_out, @field20_value)
end

select
	@msgbox_title = coalesce(@msgbox_title, 'P21 Rule')
	,@results = coalesce(@results, '')
	,@status = coalesce(@status, 1)

/*
grant execute on ydbc_dr_multiuse to pxxiuser
grant execute on ydbc_dr_multiuse to public
*/

