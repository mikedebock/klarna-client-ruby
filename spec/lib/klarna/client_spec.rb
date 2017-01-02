# encoding: UTF-8

require 'spec_helper'

describe Klarna::Client do
  include ConfigurationHelper

  let(:client) { build(:client) }

  let(:person_address) do
    {
      :email           => 'always_approved@klarna.com',
      :telno           => '',
      :cellno          => '0762560000',
      :fname           => 'Testperson-se',
      :lname           => 'Approved',
      :company         => '',
      :careof          => '',
      :street          => 'Stårgatan 1',
      :house_number    => '',
      :house_extension => '',
      :zip             => '12345',
      :city            => 'Ankeborg',
      :country         => 209
    }
  end

  let(:reserve_amount_goods_list) do
    [
      {
        :goods => {
          :artno    => 'article1',
          :title    => 'Article Foo',
          :price    => 199,
          :vat      => 25,
          :discount => 0,
          :flags    => Klarna::Constants::VAT_INCLUDED
        },
        :qty   => 1
      },
      {
        :goods => {
          :artno    => 'article2',
          :title    => 'Article Poo',
          :price    => 100,
          :vat      => 25,
          :discount => 0,
          :flags    => Klarna::Constants::VAT_INCLUDED
        },
        :qty   => 1
      }
    ]
  end

  let(:reserve_amount_params) do
    {
      :amount           => 299,
      :billing_address  => person_address,
      :country          => 209,
      :currency         => 0,
      :delivery_address => person_address,
      :flags            => Klarna::Constants::TEST_PERSON_FLAG,
      :goods_list       => reserve_amount_goods_list,
      :language         => 138,
      :pclass           => -1,
      :pno              => Klarna::Constants::TestPersonPnos::SE.first,
      :pno_encoding     => Klarna::Constants::GET_ADDRESSES_PNO_ENCODING_SE,
      :shipment_info    => { :delay_adjust => 1 },
    }
  end

  describe 'get_addresses' do
    let(:person_addresses) do
      [
        [
          'Testperson-se',
          'Approved',
          'Stårgatan 1',
          '12345',
          'Ankeborg',
          '209'
        ]
      ]
    end

    let(:person_addresses_with_tno) do
      [
        [
          '410321-9202', # formatted version of Klarna::Constants::TestPersonPnos::SE.first
          'Testperson-se',
          'Approved',
          'Stårgatan 1',
          '12345',
          'Ankeborg',
          209
        ]
      ]
    end

    let(:company_addresses) do
      [
        [
          'Testcompany-se',
          'Stårgatan 1',
          '12345',
          'Ankeborg',
          '209'
        ],
        [
          'Testcompany-se',
          'lillegatan 1',
          '12334',
          'Ankeborg',
          '209'
        ]
      ]
    end

    describe 'instance method' do

      before do
        setup_configuration
      end

      it 'returns the expected response for a person PNO' do
        VCR.use_cassette 'get_addresses for person PNO' do
          addresses = client.get_addresses(:pno          => Klarna::Constants::TestPersonPnos::SE.first,
                                           :pno_encoding => Klarna::Constants::GET_ADDRESSES_PNO_ENCODING_SE,
                                           :type         => Klarna::Constants::GET_ADDRESSES_TYPE_PNO)

          expect(addresses).to eq(person_addresses)
        end
      end

      it 'returns the expected response for a company PNO' do
        VCR.use_cassette 'get_addresses for company PNO' do
          addresses = client.get_addresses(:pno          => Klarna::Constants::TestCompanyPnos::SE.first,
                                           :pno_encoding => Klarna::Constants::GET_ADDRESSES_PNO_ENCODING_SE,
                                           :type         => Klarna::Constants::GET_ADDRESSES_TYPE_PNO)

          expect(addresses).to eq(company_addresses)
        end
      end

      it 'returns the expected response for a person TNO' do
        VCR.use_cassette 'get_addresses for a person TNO' do
          addresses = client.get_addresses(:tno          => Klarna::Constants::TestPersonTnos::SE.first,
                                           :pno_encoding => Klarna::Constants::GET_ADDRESSES_PNO_ENCODING_SE,
                                           :type         => Klarna::Constants::GET_ADDRESSES_TYPE_TNO)

          expect(addresses).to eq(person_addresses_with_tno)
        end
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        expect(client).to receive(:get_addresses).with(params).and_return('OK')

        expect(Klarna::Client.get_addresses(params)).to eq('OK')
      end
    end
  end

  describe 'reserve_amount' do
    describe 'instance method' do

      before do
        VCR.use_cassette 'reserve amount' do
          @reservation = client.reserve_amount(reserve_amount_params)
        end
      end

      it 'returns an array' do
        expect(@reservation).to be_an(Array)
      end

      it 'first element is a string representing the reservation number' do
        expect(@reservation.first).to be_a(String)
      end

      it 'second element is an integer representing the reservation status' do
        expect(@reservation.last).to eq(1)
      end
    end
  end

  describe 'class method' do

    before do
      setup_configuration
      allow(Klarna::Client).to receive(:new).and_return(client)
    end

    it 'delegates to the client' do
      params = Object.new
      expect(client).to receive(:reserve_amount).with(params).and_return('OK')

      expect(Klarna::Client.reserve_amount(params)).to eq('OK')
    end
  end

  describe 'activate' do
    describe 'instance method' do

      before do
        VCR.use_cassette 'activate' do
          reservation_id = client.reserve_amount(reserve_amount_params).first
          @invoice       = client.activate(:rno => reservation_id, :optional_info => { :flags => Klarna::Constants::TEST_PERSON_FLAG })
        end
      end

      it 'returns an array' do
        expect(@invoice).to be_an(Array)
      end

      it 'first element is a string representing the risk status' do
        expect(@invoice.first).to eq("ok")
      end

      it 'second is a string representing the invoice number' do
        expect(@invoice.last).to be_a(String)
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        expect(client).to receive(:activate).with(params).and_return('OK')

        expect(Klarna::Client.activate(params)).to eq('OK')
      end
    end
  end

  describe 'credit_invoice' do
    describe 'instance method' do

      before do
        VCR.use_cassette 'credit invoice' do
          reservation_id  = client.reserve_amount(reserve_amount_params).first
          @invno          = client.activate(:rno => reservation_id, :optional_info => { :flags => Klarna::Constants::TEST_PERSON_FLAG }).last
          @invoice_number = client.credit_invoice(:invno => @invno)
        end
      end

      it 'returns a string' do
        expect(@invoice_number).to be_a(String)
      end

      it 'returns a string representing the invoice number' do
        expect(@invoice_number).to eq(@invno)
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        expect(client).to receive(:credit_invoice).with(params).and_return('12345')

        expect(Klarna::Client.credit_invoice(params)).to eq('12345')
      end
    end
  end

  describe 'cancel_reservation' do
    describe 'instance method' do

      before do
        VCR.use_cassette 'cancel' do
          reservation_id = client.reserve_amount(reserve_amount_params).first
          @status        = client.cancel_reservation(:rno => reservation_id)
        end
      end

      it 'returns ok status' do
        expect(@status).to eq('ok')
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        expect(client).to receive(:cancel_reservation).with(params).and_return('ok')

        expect(Klarna::Client.cancel_reservation(params)).to eq('ok')
      end
    end
  end

  describe 'get_payref_id' do

    describe 'instance method' do

      before do
        VCR.use_cassette 'get payref id' do
          @payref = client.get_payref_id
        end
      end

      it 'returns payref id' do
        expect(@payref).to be_a(String)
      end
    end

    describe 'class method' do
      let(:payref) { 'PAYREF' }

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        expect(client).to receive(:get_payref_id).and_return(payref)

        expect(Klarna::Client.get_payref_id).to eq(payref)
      end
    end
  end

  describe 'create_prepaid_order' do
    let(:params) do
      {
        :country       => 209,
        :language      => 138,
        :currency      => 0,
        :goods_list    => goods_list,
        :payment_info  => payment_info,
        :customer_info => customer_info
      }
    end

    let(:goods_list) do
      [
        {
          :goods => {
            :artno    => 'article1',
            :title    => 'Article Foo',
            :price    => 199,
            :vat      => 25,
            :discount => 0,
            :flags    => Klarna::Constants::VAT_INCLUDED
          },
          :qty   => 1
        }
      ]
    end

    let(:payment_info) do
      {
        :external_payref_id => "EXT_ID_1234567",
        :payref_id          => @payref,
        :service_type       => 'credit_card',
        :bank_name          => 'Valitor',
        :payment_connector  => 'payon'
      }
    end

    let(:customer_info) do
      {
        :phone   => "+46700029099",
        :contact => {}
      }
    end

    describe 'instance method' do

      before do
        VCR.use_cassette 'create prepaid order' do
          @payref         = client.get_payref_id
          @invoice_number = client.create_prepaid_order(params).last
        end
      end

      it 'returns invoice_number' do
        expect(@invoice_number).to be_a(String)
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        expect(client).to receive(:create_prepaid_order).with(params).and_return('12345')

        expect(Klarna::Client.create_prepaid_order(params)).to eq('12345')
      end
    end
  end

  describe 'check_order_status' do
    let(:type) { 0 }
    let(:params) do
      {
        :id   => @reservation_id,
        :type => type,
      }
    end

    describe 'instance method' do

      before do
        VCR.use_cassette 'check order status' do
          @reservation_id = client.reserve_amount(reserve_amount_params).first
          @status         = client.check_order_status(params)
        end
      end

      it 'returns ok status' do
        expect(@status).to eq(1)
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        allow(client).to receive(:check_order_status).with(params).and_return(1)

        expect(Klarna::Client.check_order_status(params)).to eq(1)
      end
    end
  end

  describe 'credit_part' do
    let(:goods_list) do
      [
        {
          :goods => {
            :artno    => 'article3',
            :title    => 'Article Foo',
            :price    => 199,
            :vat      => 25,
            :discount => 0,
            :flags    => Klarna::Constants::VAT_INCLUDED
          },
          :qty   => 1
        }
      ]
    end

    let(:params) do
      {
        :invoice_number => @invoice_number,
        :credno         => '',
        :flags          => Klarna::Constants::TEST_PERSON_FLAG,
        # Just a note - this is undocumented in the public API and is only available for
        # Klarna::Constants::AGGREGATED_INVOICE_FLAG type invoices
        :goods_list     => goods_list,
      }
    end

    describe 'instance method' do

      before do
        VCR.use_cassette 'credit_part instance method' do
          reservation_id  = client.reserve_amount(reserve_amount_params).first
          flags           = Klarna::Constants::TEST_PERSON_FLAG | Klarna::Constants::AGGREGATED_INVOICE_FLAG
          @invoice_number = client.activate(:rno => reservation_id, :optional_info => { :flags => flags }).last
          @result         = client.credit_part(params)
        end
      end

      it 'returns a string representing the invoice number' do
        expect(@result).to eq(@invoice_number)
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        allow(client).to receive(:credit_part).with(params).and_return('OK')

        expect(Klarna::Client.credit_part(params)).to eq('OK')
      end
    end
  end

  describe 'add_invoice' do
    let(:person_address) do
      {
        :email           => 'always_approved@klarna.com',
        :telno           => '',
        :cellno          => '0762560000',
        :fname           => 'Testperson-se',
        :lname           => 'Approved',
        :company         => '',
        :careof          => '',
        :street          => 'Stårgatan 1',
        :house_number    => '',
        :house_extension => '',
        :zip             => '12345',
        :city            => 'Ankeborg',
        :country         => 209
      }
    end

    let(:goods_list) do
      [
        {
          :goods => {
            :artno    => 'article#',
            :title    => 'Article Foo',
            :price    => 199,
            :vat      => 25,
            :discount => 0,
            :flags    => Klarna::Constants::VAT_INCLUDED
          },
          :qty   => 1
        }
      ]
    end

    let(:params) do
      {
        :amount           => 199,
        :billing_address  => person_address,
        :country          => 209,
        :currency         => 0,
        :delivery_address => person_address,
        :flags            => Klarna::Constants::TEST_PERSON_FLAG,
        :goods_list       => goods_list,
        :language         => 138,
        :pclass           => -1,
        :pno              => Klarna::Constants::TestPersonPnos::SE.first,
        :pno_encoding     => Klarna::Constants::GET_ADDRESSES_PNO_ENCODING_SE,
        :shipment_info    => { :delay_adjust => 1 },
        :client_ip        => '194.42.67.50'
      }
    end

    describe 'instance method' do

      before do
        VCR.use_cassette 'add invoice' do
          @reservation = client.add_invoice(params)
        end
      end

      it 'returns an array' do
        expect(@reservation).to be_an(Array)
      end

      describe 'first element of the response' do
        it 'is a string representing the reservation number' do
          expect(@reservation.first).to be_a(String)
        end
      end

      describe 'second element of the response' do
        it 'is an integer representing the reservation status' do
          expect(@reservation.last).to eq(1)
        end
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        allow(client).to receive(:add_invoice).with(params).and_return('OK')

        expect(Klarna::Client.add_invoice(params)).to eq('OK')
      end
    end
  end

  describe 'lookup_invoice' do
    let(:orderno) { 'orderid1234' }

    describe 'instance method' do

      before do
        VCR.use_cassette 'lookup_invoice' do
          reservation_id = client.reserve_amount(reserve_amount_params).first
          client.activate(:rno => reservation_id, :optional_info => {:flags => Klarna::Constants::TEST_PERSON_FLAG, :orderid1 => orderno}).last
          @invoice_list = client.lookup_invoice({ orderno: orderno })
        end
      end

      it 'returns an array' do
        expect(@invoice_list).to be_an(Array)
      end

      it 'returns an item representing an invoice number' do
        expect(@invoice_list.first).to_not be_nil
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        expect(client).to receive(:lookup_invoice).with(params).and_return('ok')

        expect(Klarna::Client.lookup_invoice(params)).to eq('ok')
      end
    end
  end

  describe 'order_info' do
    describe 'instance method' do

      before do
        VCR.use_cassette 'order_info' do
          reservation_id = client.reserve_amount(reserve_amount_params).first
          @invoice_number = client.activate(:rno => reservation_id, :optional_info => {:flags => Klarna::Constants::TEST_PERSON_FLAG}).last
          @order_information = client.order_info({ invno: @invoice_number })
        end
      end

      it 'returns an array' do
        expect(@order_information).to be_an(Array)
      end

      it 'returns a string representing the payment method' do
        expect(@order_information[0]).to be_a(String)
      end

      it 'returns a string representing the due date' do
        expect(@order_information[1]).to be_a(String)
      end

      it 'returns a string representing whether is paid' do
        expect(@order_information[2]).to be_a(String)
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        expect(client).to receive(:order_info).with(params).and_return('ok')

        expect(Klarna::Client.order_info(params)).to eq('ok')
      end
    end
  end

  describe 'extend_invoice_due_date' do
    let(:extend_invoice_due_date_params) do
      {
          invno: @invoice_number,
          extra_info: { days: 14, calculate_only: 1 }
      }
    end

    describe 'instance method' do

      before do
        VCR.use_cassette 'extend_invoice_due_date' do
          reservation_id = client.reserve_amount(reserve_amount_params).first
          @invoice_number = client.activate(:rno => reservation_id, :optional_info => {:flags => Klarna::Constants::TEST_PERSON_FLAG}).last
          @extended_date = client.extend_invoice_due_date(extend_invoice_due_date_params)
        end
      end

      it 'returns a hash' do
        expect(@extended_date).to be_an(Hash)
      end

      it 'returns a string representing the new date' do
        expect(@extended_date['new_date']).to be_a(String)
      end

      it 'returns a fixnum representing the cost' do
        expect(@extended_date['cost']).to be_a(Fixnum)
      end
    end

    describe 'class method' do

      before do
        setup_configuration
        allow(Klarna::Client).to receive(:new).and_return(client)
      end

      it 'delegates to the client' do
        params = Object.new
        expect(client).to receive(:extend_invoice_due_date).with(params).and_return('ok')

        expect(Klarna::Client.extend_invoice_due_date(params)).to eq('ok')
      end
    end
  end

  describe '.ping' do
    let(:response) { double }
    let(:connection) { double }

    before do
      allow(Klarna::Client).to receive(:status_connection).and_return(connection)
      allow(connection).to receive(:get).and_return(response)
    end

    it 'returns a successful response when status call is successful' do
      allow(response).to receive(:success?).and_return(true)

      response = Klarna::Client.ping

      expect(response).to eq [true, nil]
    end

    it 'returns an unsuccessful response when status call is unsuccessful' do
      allow(response).to receive(:success?).and_return(false)

      response = Klarna::Client.ping

      expect(response).to eq [false, nil]
    end

    it 'returns an error response when status call raises an error' do
      error = StandardError.new("ping not smoooth enough")
      allow(connection).to receive(:get).and_raise(error)

      response = Klarna::Client.ping

      expect(response).to eq [false, error]
    end
  end

  describe 'instrumentation' do
    before do
      setup_configuration
      allow(Klarna::Client).to receive(:new).and_return(client)
    end

    around(:each) do |example|
      @instrumentation_params  = nil
      @xml_rpc_method          = nil
      @xml_rpc_response_values = nil
      @xml_rpc_fault_code      = nil

      subscription = ActiveSupport::Notifications.subscribe('request.klarna_client') do |name, starts, ends, _, data|
        @instrumentation_params  = data[:params]
        @xml_rpc_method          = data[:method].xmlrpc_name
        @xml_rpc_response_values = data[:response_values]
        @xml_rpc_fault_code      = data[:xmlrpc_fault_code]
      end

      example.run

      ActiveSupport::Notifications.unsubscribe(subscription)
    end

    it "doesn't send a notification when use_instrumentation is not set" do
      allow(client).to receive(:xml_rpccall).and_return('A')
      allow(Klarna.configuration).to receive(:use_instrumentation?).and_return(false)

      client.create_prepaid_order(goji: 'berries')

      expect(@instrumentation_params).to be_nil
      expect(@xml_rpc_method).to be_nil
      expect(@xml_rpc_response_values).to be_nil
    end

    it 'sends a notification when use_instrumentation is true' do
      Klarna.configuration.use_instrumentation!
      allow(client).to receive(:xml_rpccall).with(Klarna::Methods::CreatePrepaidOrder, hashkedia: 'porahat').and_return('A')

      client.create_prepaid_order(hashkedia: 'porahat')

      expect(client).to have_received(:xml_rpccall).with(Klarna::Methods::CreatePrepaidOrder, hashkedia: 'porahat')
      expect(@instrumentation_params).to eq(hashkedia: 'porahat', estore_id: ENV['KLARNA_STORE_ID'].to_i, client_name: ENV['CLIENT_NAME'])
      expect(@xml_rpc_method).to eq('create_prepaid_order')
      expect(@xml_rpc_response_values).to eq('A')
    end

    it 'includes the faultCode in the data when use_instrumentation is true and a request fails with a XMLRPC::FaultException' do
      Klarna.configuration.use_instrumentation!
      allow(client).to receive(:xml_rpccall).with(Klarna::Methods::CreatePrepaidOrder, hashkedia: 'porahat').and_raise XMLRPC::FaultException.new(888, 'gambling is no good')

      client.create_prepaid_order(hashkedia: 'porahat') rescue nil

      expect(client).to have_received(:xml_rpccall).with(Klarna::Methods::CreatePrepaidOrder, hashkedia: 'porahat')
      expect(@xml_rpc_fault_code).to eq(888)
      expect(@instrumentation_params).to eq(hashkedia: 'porahat', estore_id: ENV['KLARNA_STORE_ID'].to_i, client_name: ENV['CLIENT_NAME'])
      expect(@xml_rpc_method).to eq('create_prepaid_order')
      expect(@xml_rpc_response_values).to be_nil
    end
  end
end
