defmodule Explorer.Chain.Address.CurrentTokenBalance do
  @moduledoc """
  Represents the current token balance from addresses according to the last block.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Explorer.Chain.{Address, Block, Hash, Token}

  @typedoc """
   *  `address` - The `t:Explorer.Chain.Address.t/0` that is the balance's owner.
   *  `address_hash` - The address hash foreign key.
   *  `token` - The `t:Explorer.Chain.Token/0` so that the address has the balance.
   *  `token_contract_address_hash` - The contract address hash foreign key.
   *  `block_number` - The block's number that the transfer took place.
   *  `value` - The value that's represents the balance.
  """
  @type t :: %__MODULE__{
          address: %Ecto.Association.NotLoaded{} | Address.t(),
          address_hash: Hash.Address.t(),
          token: %Ecto.Association.NotLoaded{} | Token.t(),
          token_contract_address_hash: Hash.Address,
          block_number: Block.block_number(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          value: Decimal.t() | nil
        }

  schema "address_current_token_balances" do
    field(:value, :decimal)
    field(:block_number, :integer)
    field(:value_fetched_at, :utc_datetime)

    belongs_to(:address, Address, foreign_key: :address_hash, references: :hash, type: Hash.Address)

    belongs_to(
      :token,
      Token,
      foreign_key: :token_contract_address_hash,
      references: :contract_address_hash,
      type: Hash.Address
    )

    timestamps()
  end

  @optional_fields ~w(value value_fetched_at)a
  @required_fields ~w(address_hash block_number token_contract_address_hash)a
  @allowed_fields @optional_fields ++ @required_fields

  @doc false
  def changeset(%__MODULE__{} = token_balance, attrs) do
    token_balance
    |> cast(attrs, @allowed_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:address_hash)
    |> foreign_key_constraint(:token_contract_address_hash)
  end
end
