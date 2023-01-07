defmodule FrontendWeb.ProductsController do
  use FrontendWeb, :controller
  require Logger

  @price_ids Application.compile_env(:frontend, __MODULE__)

  def index(conn, _params) do
    # Our button
    render(conn, "index.html")
  end

  def order(conn, %{"tier" => tier}) do
    Logger.warn("GOT REQUEST FOR: #{tier}")
    email = "foo@bar.com"
    # Or if it is a recurring customer, you can provide customer_id
    customer_id = get_customer_from_email(email)
    # Get this from the Stripe dashboard for your product
    price_id =
      case tier do
        "500" -> price_id?(500)
        "1000" -> price_id?(1000)
        "5000" -> price_id?(5000)
        "10000" -> price_id?(10000)
        "50000" -> price_id?(50000)
        "100000" -> price_id?(100_000)
      end

    session_config = %{
      # success_url: ~p"/stripe/success",
      success_url: url(~p"/stripe/success"),
      cancel_url: url(~p"/stripe/cancel"),
      mode: "subscription",
      line_items: [
        %{
          price: price_id,
          quantity: 1
        }
      ]
    }

    # Previous customer? customer_id else customer_email
    # The stripe API only allows one of {customer_email, customer}
    session_config =
      if customer_id,
        do: Map.put(session_config, :customer, customer_id),
        else: Map.put(session_config, :customer_email, email)

    case Stripe.Session.create(session_config) do
      {:ok, session} ->
        redirect(conn, external: session.url)

      {:error, stripe_error} ->
        Logger.error("Got a stripe error: #{inspect(stripe_error)}")
        # TODO: Handle error (object Stripe.Error)
        render(conn, "index.html")
    end
  end

  #  %{
  #    "api_version" => "2022-08-01",
  #    "created" => 1_667_142_389,
  #    "data" => %{
  #      "object" => %{
  #        "shipping" => nil,
  #        "id" => "ch_3Lyd5kK9nGiZx2np0OaCM5e0",
  #        "transfer_data" => nil,
  #        "statement_descriptor_suffix" => nil,
  #        "application_fee_amount" => nil,
  #        "disputed" => false,
  #        "transfer_group" => nil,
  #        "status" => "succeeded",
  #        "source_transfer" => nil,
  #        "destination" => nil,
  #        "dispute" => nil,
  #        "created" => 1_667_142_389,
  #        "currency" => "usd",
  #        "refunded" => false,
  #        "amount_refunded" => 0,
  #        "captured" => true,
  #        "source" => nil,
  #        "billing_details" => %{
  #          "address" => %{
  #            "city" => nil,
  #            "country" => "PT",
  #            "line1" => nil,
  #            "line2" => nil,
  #            "postal_code" => nil,
  #            "state" => nil
  #          },
  #          "email" => "hello@foo.com",
  #          "name" => "trest",
  #          "phone" => nil
  #        },
  #        "order" => nil,
  #        "amount_captured" => 2900,
  #        "object" => "charge",
  #        "failure_code" => nil,
  #        "receipt_number" => nil,
  #        "failure_balance_transaction" => nil,
  #        "receipt_email" => nil,
  #        "application" => nil,
  #        "balance_transaction" => "txn_3Lyd5kK9nGiZx2np0FZbWTSx",
  #        "statement_descriptor" => nil,
  #        "payment_method_details" => %{
  #          "card" => %{
  #            "brand" => "visa",
  #            "checks" => %{
  #              "address_line1_check" => nil,
  #              "address_postal_code_check" => nil,
  #              "cvc_check" => "pass"
  #            },
  #            "country" => "US",
  #            "exp_month" => 12,
  #            "exp_year" => 2023,
  #            "fingerprint" => "jlNIgZbAlohC8gAj",
  #            "funding" => "credit",
  #            "installments" => nil,
  #            "last4" => "4242",
  #            "mandate" => nil,
  #            "network" => "visa",
  #            "three_d_secure" => nil,
  #            "wallet" => nil
  #          },
  #          "type" => "card"
  #        },
  #        "invoice" => "in_1Lyd5kK9nGiZx2npi1YG9bU5",
  #        "outcome" => %{
  #          "network_status" => "approved_by_network",
  #          "reason" => nil,
  #          "risk_level" => "normal",
  #          "risk_score" => 36,
  #          "seller_message" => "Payment complete.",
  #          "type" => "authorized"
  #        },
  #        "amount" => 2900,
  #        "fraud_details" => %{},
  #        "customer" => "cus_Mi3CEJIlCSt6FB",
  #        "on_behalf_of" => nil,
  #        "refunds" => %{
  #          "data" => [],
  #          "has_more" => false,
  #          "object" => "list",
  #          "total_count" => 0,
  #          "url" => "/v1/charges/ch_3Lyd5kK9nGiZx2np0OaCM5e0/refunds"
  #        },
  #        "payment_intent" => "pi_3Lyd5kK9nGiZx2np0PY79KFI",
  #        "review" => nil,
  #        "failure_message" => nil,
  #        "application_fee" => nil,
  #        "paid" => true,
  #        "description" => "Subscription creation",
  #        "metadata" => %{},
  #        "calculated_statement_descriptor" => "TERMITE LAB",
  #        "livemode" => false,
  #        "payment_method" => "pm_1Lyd5jK9nGiZx2npn7HqXpFU"
  #      }
  #    },
  #    "id" => "evt_3Lyd5kK9nGiZx2np0A5gcPJ0",
  #    "livemode" => false,
  #    "object" => "event",
  #    "pending_webhooks" => 2,
  #    "request" => %{
  #      "id" => "req_NmgFyvCUXHgF3i",
  #      "idempotency_key" => "44fe8a4e-1e0c-4cc5-bdd7-a2941bcefc01"
  #    },
  #    "type" => "charge.succeeded"
  #  }
  # for now, let'sjust accept that we have asuccess call and map the cstomer to
  # the user and track what tier they are on.we cxan then rely on stripe to do
  # the right thing for or customers to show them the active sscription
  def success(conn, %{"type" => "charge.succeeded"} = params) do
    Logger.debug("** do something with #{params[:type]}")

    _email = params["data"]["object"]["billing_details"]["email"]
    _customer = params["data"]["oject"]["customer"]

    conn
    |> redirect(to: ~p"/dashboard")
  end

  #  %{
  #    "api_version" => "2022-08-01",
  #    "created" => 1_667_142_390,
  #    "data" => %{
  #      "object" => %{
  #        "shipping_options" => [],
  #        "id" => "cs_test_a15myuFqdvv6Rfz5uuInIx85fGidsk0nwuKGnVDaxT5Jxgz5UGJq8R77mQ",
  #        "consent" => nil,
  #        "shipping_details" => nil,
  #        "status" => "complete",
  #        "cancel_url" => "http://localhost:4000/products/new/cancel",
  #        "billing_address_collection" => nil,
  #        "allow_promotion_codes" => nil,
  #        "subscription" => "sub_1Lyd5kK9nGiZx2npDgrv8KVv",
  #        "url" => nil,
  #        "payment_method_collection" => "always",
  #        "amount_total" => 2900,
  #        "amount_subtotal" => 2900,
  #        "created" => 1_667_142_371,
  #        "currency" => "usd",
  #        "after_expiration" => nil,
  #        "client_reference_id" => nil,
  #        "setup_intent" => nil,
  #        "automatic_tax" => %{"enabled" => false, "status" => nil},
  #        "expires_at" => 1_667_228_771,
  #        "total_details" => %{"amount_discount" => 0, "amount_shipping" => 0, "amount_tax" => 0},
  #        "object" => "checkout.session",
  #        "recovered_from" => nil,
  #        "success_url" => "http://10.27.6.6:4000/stripe/success",
  #        "mode" => "subscription",
  #        "submit_type" => nil,
  #        "shipping_cost" => nil,
  #        "customer" => "cus_Mi3CEJIlCSt6FB",
  #        "phone_number_collection" => %{"enabled" => false},
  #        "customer_details" => %{
  #          "address" => %{
  #            "city" => nil,
  #            "country" => "PT",
  #            "line1" => nil,
  #            "line2" => nil,
  #            "postal_code" => nil,
  #            "state" => nil
  #          },
  #          "email" => "hello@foo.com",
  #          "name" => "trest",
  #          "phone" => nil,
  #          "tax_exempt" => "none",
  #          "tax_ids" => []
  #        },
  #        "customer_email" => "hello@foo.com",
  #        "payment_intent" => nil,
  #        "consent_collection" => nil,
  #        "shipping_address_collection" => nil,
  #        "locale" => nil,
  #        "payment_method_types" => ["card"],
  #        "metadata" => %{},
  #        "payment_link" => nil,
  #        "customer_creation" => "always",
  #        "payment_method_options" => nil,
  #        "livemode" => false,
  #        "payment_status" => "paid"
  #      }
  #    },
  #    "id" => "evt_1Lyd5mK9nGiZx2nppLbwWj0p",
  #    "livemode" => false,
  #    "object" => "event",
  #    "pending_webhooks" => 2,
  #    "request" => %{"id" => nil, "idempotency_key" => nil},
  #    "type" => "checkout.session.completed"
  #  }
  #
  #  %{
  #    "api_version" => "2022-08-01",
  #    "created" => 1_667_142_389,
  #    "data" => %{
  #      "object" => %{
  #        "billing_details" => %{
  #          "address" => %{
  #            "city" => nil,
  #            "country" => "PT",
  #            "line1" => nil,
  #            "line2" => nil,
  #            "postal_code" => nil,
  #            "state" => nil
  #          },
  #          "email" => "hello@foo.com",
  #          "name " => "trest",
  #          "phone" => nil
  #        },
  #        "card" => %{
  #          "brand" => "visa",
  #          "checks" => %{
  #            "address_line1_check" => nil,
  #            "address_postal_code_check" => nil,
  #            "cvc_check" => "pass"
  #          },
  #          "country" => "US",
  #          "exp_month" => 12,
  #          "exp_year" => 2023,
  #          "fingerprint" => "jlNIgZbAlohC8gAj",
  #          "funding" => "credit",
  #          "generated_from" => nil,
  #          "last4" => "4242",
  #          "networks" => %{"available" => ["visa"], "preferred" => nil},
  #          "three_d_secure_usage" => %{"supported" => true},
  #          "wallet" => nil
  #        },
  #        "created" => 1_667_142_387,
  #        "customer" => "cus_Mi3CEJIlCSt6FB",
  #        "id" => "pm_1Lyd5jK9nGiZx2npn7HqXpFU",
  #        "livemode" => false,
  #        "metadata" => %{},
  #        "object" => "payment_method",
  #        "type" => "card"
  #      }
  #    },
  #    "id" => "evt_1Lyd5mK9nGiZx2npEIAujHO6",
  #    "livemode" => false,
  #    "object" => "event",
  #    "pending_webhooks" => 2,
  #    "request" => %{"id" => "req_NmgFyvCUXHgF3i", 
  #    "idempotency_key" => "44fe8a4e-1e0c-4cc5-bdd7-a2941bcefc01"},
  #    "type" => "payment_method.attached"
  #  }
  #
  #  %{
  #    "api_version" => "2022-08-01",
  #    "created" => 1_667_142_388,
  #    "data" => %{
  #      "object" => %{
  #        "address" => %{
  #          "city" => nil,
  #          "country" => "PT",
  #          "line1" => nil,
  #          "line2" => nil,
  #          "postal_code" => nil,
  #          "state" => nil
  #        },
  #        "balance" => 0,
  #        "created" => 1_667_142_387,
  #        "currency" => " usd",
  #        "default_source" => nil,
  #        "delinquent" => false,
  #        "description" => nil,
  #        "discount" => nil,
  #        "email" => "hello@foo.com",
  #        "id" => "cus_Mi3CEJIlCSt6FB",
  #        "invoice_prefix" => "F07125E9",
  #        "invoice_settings" => %{
  #          "custom_fields" => nil,
  #          "default_payment_method" => nil,
  #          "footer" => nil,
  #          "rendering_options" => nil
  #        },
  #        "livemode" => false,
  #        "metadata" => %{},
  #        "name" => "trest",
  #        "next_invoice_sequence" => 2,
  #        "object" => "customer",
  #        "phone" => nil,
  #        "preferred_locales" => ["en-US"],
  #        "shipping" => nil,
  #        "tax_exempt" => "none",
  #        "test_clock" => nil
  #      },
  #      "previou s_attributes" => %{"currency" => nil}
  #    },
  #    "id" => "evt_1Lyd5nK9nGiZx2npqNVPSbJP",
  #    "livemode" => false,
  #    "object" => "event",
  #    "pending_webhooks" => 2,
  #    "request" => %{
  #      "id" => "req_NmgFyvCUXHgF3i",
  #      "idempotency_key" => "44fe8a4e-1e0c-4cc5-bdd7-a2941bcefc01"
  #    },
  #    "type" => "customer. updated"
  #  }

  # 
  #  %{
  #    "api_version" => "2022-08-01",
  #    "created" => 1_667_142_388,
  #    "data" => %{
  #      "object" => %{
  #        "lines" => %{
  #          "data" => [
  #            %{
  #              "amount" => 2900,
  #              "amount_excluding_tax" => 2900,
  #              "currency" => "usd",
  #              "description" => "1 × 5000 Email Verifications / Month (at $29.00 / month)",
  #              "discount_amounts" => [],
  #              "discountable" => true,
  #              "discounts" => [],
  #              "id" => "il_1Lyd5kK9nGiZx2npfKdmPOJb",
  #              "livemode" => false,
  #              "metadata" => %{},
  #              "object" => "line_item",
  #              "period" => %{"end" => 1_669_820_788, "start" => 1_667_142_388},
  #              "plan" => %{
  #                "active" => true,
  #                "aggregate_usage" => nil,
  #                "amount" => 2900,
  #                "amount_decimal" => "2900",
  #                "billing_scheme" => "per_unit",
  #                "created" => 1_666_888_931,
  #                "currency" => "usd",
  #                "id" => "price_1LxZ9jK9nGiZx2np3PqApaaS",
  #                "interval" => "month",
  #                "interval_count" => 1,
  #                "livemode" => false,
  #                "metadata " => %{},
  #                "nickname" => nil,
  #                "object" => "plan",
  #                "product" => "prod_Mgx3Eg2JeX0BwK",
  #                "tiers_mode" => nil,
  #                "transform_usage" => nil,
  #                "trial_period_days" => nil,
  #                "usage_type" => "licensed"
  #              },
  #              "price" => %{
  #                "active" => true,
  #                "billing_scheme" => "per_unit",
  #                "created" => 1_666_888_931,
  #                "currency" => "usd",
  #                "custom_unit_amount" => nil,
  #                "id" => "price_1LxZ9jK9nGiZx2np3PqApaaS",
  #                "livemode" => false,
  #                "lookup_key" => nil,
  #                "metadata" => %{},
  #                "nickname" => nil,
  #                "object" => "price",
  #                "product" => "prod_Mgx3Eg2JeX0BwK",
  #                "recurring" => %{
  #                  "aggregate_usage" => nil,
  #                  "interval" => "month",
  #                  "interval_count" => 1,
  #                  "trial_period_days" => nil,
  #                  "usage_type" => "licensed"
  #                },
  #                "tax_behavior" => "inclusive",
  #                "tiers_mode" => nil,
  #                "transform_quantity" => nil,
  #                "type" => "recurring",
  #                "unit_amount" => 2900,
  #                "unit_amount_decimal" => "2900"
  #              },
  #              "proratio n" => false,
  #              "proration_details" => %{"credited_items" => nil},
  #              "quantity" => 1,
  #              "subscription" => "sub_1Lyd5kK9nGiZx2npDgrv8KVv",
  #              "subscription_item" => "si_Mi3C1Qom5gFtOm",
  #              "tax_amounts" => [],
  #              "tax_rates" => [],
  #              "type" => "subscription",
  #              "unit_amount_excluding_tax" => "2 900"
  #            }
  #          ],
  #          "has_more" => false,
  #          "object" => "list",
  #          "total_count" => 1,
  #          "url" => "/v1/invoices/in_1Lyd5kK9nGiZx2npi1YG9bU5/lines"
  #        },
  #        "default_tax_rates" => [],
  #        "id" => "in_1Lyd5kK9nGiZx2npi1YG9bU5",
  #        "attempted" => false,
  #        "transfer_data" => nil,
  #        "period_start" => 1_667_142_388,
  #        "ta x" => nil,
  #        "application_fee_amount" => nil,
  #        "number" => "F07125E9-0001",
  #        "customer_address" => %{
  #          "city" => nil,
  #          "country" => "PT",
  #          "line1" => nil,
  #          "line2" => nil,
  #          "postal_code" => nil,
  #          "state" => nil
  #        },
  #        "ending_balance" => 0,
  #        "status" => "open",
  #        "from_invoice" => nil,
  #        "total _tax_amounts" => [],
  #        "webhooks_delivered_at" => nil,
  #        "subscription" => "sub_1Lyd5kK9nGiZx2npDgrv8KVv",
  #        "next_payment_attempt" => nil,
  #        "period_end" => 1_667_142_388,
  #        "amount_remaining" => 2900,
  #        "quote" => nil,
  #        "discounts" => [],
  #        "created" => 1_667_142_388,
  #        "total_discount_amounts" => [],
  #        "currency" => "usd",
  #        "subtotal_excluding_tax" => 2900,
  #        "total_excluding_tax" => 2900,
  #        "automatic_tax" => %{"enabled" => false, "status" => nil},
  #        "test_clock" => nil,
  #        "post_payment_credit_notes_amount" => 0,
  #        "status_transitions" => %{
  #          "finalized_at" => 1_667_142_388,
  #          "ma rked_uncollectible_at" => nil,
  #          "paid_at" => nil,
  #          "voided_at" => nil
  #        },
  #        "latest_revision" => nil,
  #        "object" => "invoice",
  #        "billing_reason" => "subscription_create",
  #        "receipt_number" => nil,
  #        "default_source" => nil,
  #        "rendering_options" => nil,
  #        "due_date" => nil,
  #        "application" => nil,
  #        "payment_settings" => %{
  #          "default_mandate" => nil,
  #          "payment_method_options" => nil,
  #          "payment_method_types" => nil
  #        },
  #        "statement_descriptor" => nil,
  #        "hosted_invoice_url" =>
  #          "https://invoice.stripe.com/i/acct_1LxUZoK9nGiZx2np/test_YWNjdF8xTHhVWm9LOW5HaVp4Mm5wLF9NaTNDNFQ3 Y1FZR0tXbGVqemc3cTVBMGRiemwyMGdXLDU3NjgzMTkx0200dh3uSlDs?s=ap",
  #        "account_tax_ids" => nil,
  #        "amount_paid" => 0,
  #        "customer" => "cus_Mi3CEJIlCSt6FB",
  #        "account_name" => "kitty from outer space NZ Limited",
  #        "charge" => nil
  #      }
  #    },
  #    "id" => "evt_1Lyd5nK9nGiZx2npWTLaKhu2",
  #    "livemode " => false,
  #    "object" => "event",
  #    "pending_webhooks" => 2,
  #    "request" => %{
  #      "id" => "req_NmgFyvCUXHgF3i",
  #      "idempotency_key" => "44fe8a4e-1e0c-4cc5-bdd7-a2941bcefc01"
  #    },
  #    "type" => "invoice.finalized"
  #  }
  #
  #  #
  #  %{
  #    "api_version" => "2022-08-01",
  #    "created" => 1_667_142_388,
  #    "data" => %{
  #      "object" => %{
  #        "plan" => %{
  #          "active" => true,
  #          "aggregate_usage" => nil,
  #          "amount" => 2900,
  #          "amount_decimal" => "2900",
  #          "billing_scheme" => "per_unit",
  #          "created" => 1_666_888_931,
  #          "currency" => "usd",
  #          "id" => "price_1LxZ9jK9nGiZx2np3PqApaaS",
  #          "interval" => "month",
  #          "interval_count" => 1,
  #          "livemode" => false,
  #          "metadata" => %{},
  #          "nickname" => nil,
  #          "object" => "plan",
  #          "product" => "prod_Mgx3Eg2JeX0BwK",
  #          "tiers_mode" => nil,
  #          "transform_usage" => nil,
  #          "trial_period_days" => nil,
  #          "usage_type" => "licensed"
  #        },
  #        "default_tax_rates" => [],
  #        "pending_update" => nil,
  #        "id" => "sub_1Lyd5kK9nGiZx2npDgrv8KVv",
  #        "transfer_data" => nil,
  #        "items" => %{
  #          "data" => [
  #            %{
  #              "billing_thresholds" => nil,
  #              "created" => 1_667_142_388,
  #              "id" => "si_Mi3C1Qom5 gFtOm",
  #              "metadata" => %{},
  #              "object" => "subscription_item",
  #              "plan" => %{
  #                "active" => true,
  #                "aggregate_usage" => nil,
  #                "amount" => 2900,
  #                "amount_decimal" => "2900",
  #                "billing_scheme" => "per_unit",
  #                "created" => 1_666_888_931,
  #                "currency" => "usd",
  #                "id" => "price_1LxZ9jK9nGiZx2np3Pq ApaaS",
  #                "interval" => "month",
  #                "interval_count" => 1,
  #                "livemode" => false,
  #                "metadata" => %{},
  #                "nickname" => nil,
  #                "object" => "plan",
  #                "product" => "prod_Mgx3Eg2JeX0BwK",
  #                "tiers_mode" => nil,
  #                "transform_usage" => nil,
  #                "trial_period_days" => nil,
  #                "usage_type" => "licensed"
  #              },
  #              " price" => %{
  #                "active" => true,
  #                "billing_scheme" => "per_unit",
  #                "created" => 1_666_888_931,
  #                "currency" => "usd",
  #                "custom_unit_amount" => nil,
  #                "id" => "price_1LxZ9jK9nGiZx2np3PqApaaS",
  #                "livemode" => false,
  #                "lookup_key" => nil,
  #                "metadata" => %{},
  #                "nickname" => nil,
  #                "object" => "pr ice",
  #                "product" => "prod_Mgx3Eg2JeX0BwK",
  #                "recurring" => %{
  #                  "aggregate_usage" => nil,
  #                  "interval" => "month",
  #                  "interval_count" => 1,
  #                  "trial_period_days" => nil,
  #                  "usage_type" => "licensed"
  #                },
  #                "tax_behavior" => "inclusive",
  #                "tiers_mode" => nil,
  #                "transform_quantity" => nil,
  #                "type " => "recurring",
  #                "unit_amount" => 2900,
  #                "unit_amount_decimal" => "2900"
  #              },
  #              "quantity" => 1,
  #              "subscription" => "sub_1Lyd5kK9nGiZx2npDgrv8KVv",
  #              "tax_rates" => []
  #            }
  #          ],
  #          "has_more" => false,
  #          "object" => "list",
  #          "total_count" => 1,
  #          "url" => "/v1/subscription_items?subscription=sub_ 1Lyd5kK9nGiZx2npDgrv8KVv"
  #        },
  #        "status" => "incomplete",
  #        "quantity" => 1,
  #        "current_period_start" => 1_667_142_388,
  #        "trial_start" => nil,
  #        "cancel_at" => nil,
  #        "trial_end" => nil,
  #        "created" => 1_667_142_388,
  #        "currency" => "usd",
  #        "latest_invoice" => "in_1Lyd5kK9nGiZx2npi1YG9bU5",
  #        "curre nt_period_end" => 1_669_820_788,
  #        "canceled_at" => nil,
  #        "schedule" => nil,
  #        "automatic_tax" => %{"enabled" => false},
  #        "test_clock" => nil,
  #        "billing_cycle_anchor" => 1_667_142_388,
  #        "object" => "subscription",
  #        "cancel_at_period_end" => false,
  #        "default_source" => nil,
  #        "next_pending_in voice_item_invoice" => nil,
  #        "billing_thresholds" => nil,
  #        "pending_invoice_item_interval" => nil,
  #        "application" => nil,
  #        "payment_settings" => %{
  #          "payment_method_options" => nil,
  #          "payment_method_types" => nil,
  #          "save_default_payment_method" => "off"
  #        },
  #        "days_until_due" => nil,
  #        " ended_at" => nil,
  #        "customer" => "cus_Mi3CEJIlCSt6FB",
  #        "pause_collection" => nil,
  #        "on_behalf_of" => nil,
  #        "start_date" => 1_667_142_388,
  #        "discount" => nil,
  #        "pending_setup_intent" => nil,
  #        "description" => nil,
  #        "metadata" => %{},
  #        "default_payment_method" => nil,
  #        "collection_method " => "charge_automatically",
  #        "livemode" => false,
  #        "application_fee_percent" => nil
  #      }
  #    },
  #    "id" => "evt_1Lyd5nK9nGiZx2npboPbCoG6",
  #    "livemode" => false,
  #    "object" => "event",
  #    "pending_webhooks" => 2,
  #    "request" => %{
  #      "id" => "req_NmgFyvCUXHgF3i",
  #      "idempotency_key" => "44fe8a4e-1e0c- 4cc5-bdd7-a2941bcefc01"
  #    },
  #    "type" => "customer.subscription.created"
  #  }
  def success(conn, %{"type" => "customer.subscription.created"} = params) do
    Logger.debug("** do something with #{params[:type]}")

    conn
    |> redirect(to: ~p"/dashboard")
  end

  #
  #  %{
  #    "api_version" => "2022-08-01",
  #    "created" => 1_667_142_388,
  #    "data" => %{
  #      "object" => %{
  #        "shipping" => nil,
  #        "id" => "pi_3Lyd5kK9nGiZx2np0PY79KFI",
  #        "transfer_data" => nil,
  #        "statement_descriptor_suffix" => nil,
  #        "application_fee_amount" => nil,
  #        "amount_details" => %{"tip" => %{}},
  #        "transfer_group" => nil,
  #        "status" => "requires_payment_method",
  #        "cancellation_reason" => nil,
  #        "created" => 1_667_142_388,
  #        "currency" => "usd",
  #        "canceled_at" => nil,
  #        "last_payment_error" => nil,
  #        "source" => nil,
  #        "object" => "payment_intent",
  #        "receipt_email" => nil,
  #        "client_secret" => "pi_3Lyd5kK9nGiZx2np0PY79KFI_secret_bUbSOayGviMrLpDGYpTwVSRBM",
  #        "application" => nil,
  #        "statement_descriptor" => nil,
  #        "automatic_payment_methods" => nil,
  #        "invoice" => "in_1Lyd5kK9nGiZx2npi1YG9bU5",
  #        "amount" => 2900,
  #        "customer" => "cus_Mi3CEJIlCSt6FB",
  #        "on_behalf_of" => nil,
  #        "next_action" => nil,
  #        "confirmation_method" => "automatic",
  #        "review" => nil,
  #        "amount_capturable" => 0,
  #        "payment_method_types" => ["card"],
  #        "description" => "Subscription creation",
  #        "metadata" => %{},
  #        "amount_received" => 0,
  #        "charges" => %{
  #          "data" => [],
  #          "has_more" => false,
  #          "object" => "list",
  #          "total_count" => 0,
  #          "url" => "/v1/charges?payment_intent=pi_3Lyd5kK9nGiZx2np0PY79KFI"
  #        },
  #        "payment_method_options" => %{
  #          "card" => %{
  #            "installments" => nil,
  #            "mandate_options" => nil,
  #            "network" => nil,
  #            "request_three_d_secure" => "automatic"
  #          }
  #        },
  #        "capture_method" => "automatic",
  #        "processing" => nil,
  #        "livemode" => false,
  #        "payment_method" => nil,
  #        "setup_future_usage" => "off_session"
  #      }
  #    },
  #    "id" => "evt_3Lyd5kK9nGiZx2np0BQMOOrM",
  #    "livemode" => false,
  #    "object" => "event",
  #    "pending_webhooks" => 2,
  #    "request" => %{
  #      "id" => "req_NmgFyvCUXHgF3i",
  #      "idempotency_key" => "44fe8a4e-1e0c-4cc5-bdd7-a2941bcefc01"
  #    },
  #    "type" => "payment_intent.created"
  #  }
  def success(conn, %{"type" => "payment_intent.created"} = params) do
    Logger.debug("** do something with #{params[:type]}")

    conn
    |> redirect(to: ~p"/dashboard")
  end

  # catch all for unhandeled events
  def success(conn, params) do
    Logger.debug("GOT UNHANDELED FROM STRIPE: #{inspect(params)}")

    conn
    |> redirect(to: ~p"/dashboard")
  end

  def cancel(conn, _params) do
    conn
    |> put_flash(:info, "Sorry you didn't like Our Stuff.")
    |> redirect(to: ~p"/dashboard")
  end

  def edit(conn, %{"email" => email}) do
    customer_id = get_customer_from_email(email)

    session_config = %{
      customer: customer_id,
      return_url: ~p"/dashboard"
    }

    case Stripe.BillingPortal.Session.create(session_config) do
      {:ok, session} ->
        redirect(conn, external: session.url)

      {:error, stripe_error} ->
        # TODO: Handle error (object Stripe.Error)
        Logger.error("Stripe Error: #{inspect(stripe_error)}")
        render(conn, "index.html")
    end
  end

  defp get_customer_from_email(email) do
    # TODO: Handle storing and retrieving customer_id
    # Is on the format
    # customer_id = "cus_xxxxxxxxxxxxxx"
    Logger.debug("IMPLEMENT: get customer ID for #{email}")
    # "cus_MgxHq6VO5ZPNig"
    nil
  end

  defp price_id?(tier) do
    @price_ids[:products][tier]
  end
end
