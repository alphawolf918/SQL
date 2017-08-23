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