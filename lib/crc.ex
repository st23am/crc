defmodule CRC do
  use Bitwise

  @moduledoc """
  This module is used to calculate CRC (Cyclic Redundancy Check) values
  for binary data. It uses NIF functions written in C to interate over
  the given binary calculating the CRC checksum value.

  CRC implementations have been tested against these online calculators to
  validate their correctness to the best of our ability.

  https://www.lammertbies.nl/comm/info/crc-calculation.html
  http://www.sunshine2k.de/coding/javascript/crc/crc_js.html
  """

  @compile {:autoload, false}
  @on_load {:init, 0}

  @doc """
  Initilizes the module by loading NIFs
  """
  def init do
    path = :filename.join(:code.priv_dir(:crc), 'crc_nif')
    :ok = :erlang.load_nif(path, 0)
  end

  @doc """
  Calculates a 8-bit CRC with polynomial x^8+x^6+x^3+x^2+1, 0x14D.
  Chosen based on Koopman, et al. (0xA6 in his notation = 0x14D >> 1):
  http://www.ece.cmu.edu/~koopman/roses/dsn04/koopman04_crc_poly_embedded.pdf

  seed defaults to 0xFF if one is not given
  """
  @spec crc_8(binary, number) :: number
  def crc_8(<<data :: binary>>, seed \\ 0xFF) do
    _calc_8(data, seed)
  end

  @doc """
  Calculates a 16-bit ANSI CRC checksum for the provided binary
  """
  @spec crc_16(binary) :: number
  def crc_16(<<data :: binary>>) do
    _calc_16(data)
  end

  @doc """
  Calculates a 16-bit CCITT CRC with the given seed,
  seed defaults to 0xFFFF if one is not given.

  This CCIT method uses a 0x1021 polynomial.
  """
  @spec ccitt_16(binary, number) :: number
  def ccitt_16(<<data :: binary>>, seed \\ 0xFFFF) do
    _calc_16_ccitt(data, seed)
  end

  @doc """
  Calculates a 16-bit CCITT XMODEM CRC

  This CCIT method uses a 0x1021 polynomial.
  """
  @spec ccitt_16_xmodem(binary) :: number
  def ccitt_16_xmodem(<<data :: binary>>) do
    _calc_16_ccitt(data, 0x0000)
  end

  @doc """
  Calculates a 16-bit CCITT 0x1D0F CRC

  This CCIT method uses a 0x1021 polynomial.
  """
  @spec ccitt_16_1D0F(binary) :: number
  def ccitt_16_1D0F(<<data :: binary>>) do
    _calc_16_ccitt(data, 0x1D0F)
  end

  @doc """
  Calculates a 16-bit modbus CRC
  """
  @spec crc_16_modbus(binary) :: number
  def crc_16_modbus(<<data :: binary>>) do
    _calc_16_modbus(data)
  end

  #
  # @spec crc_16_sick(binary) :: number
  # def crc_16_sick(<<data :: binary>>) do
  #   0x0000
  # end
  #
  # @spec crc_dnp(binary) :: number
  # def crc_dnp(<<data :: binary>>) do
  #   0x0000
  # end

  @doc """
  Calculates an XOR checksum for the given binary
  """
  @spec checksum_xor(binary) :: number
  def checksum_xor(<<data :: binary>>) do
    _checksum_xor(data, 0)
  end

  defp _calc_8(_, _), do: "CRC NIF not loaded"
  defp _calc_16(_), do: "CRC NIF not loaded"
  defp _calc_16_ccitt(_, _), do: "CRC NIF not loaded"
  defp _calc_16_modbus(_), do: "CRC NIF not loaded"

  defp _checksum_xor(<<>>, sum), do: sum
  defp _checksum_xor(<<val :: integer-unsigned-size(8), rest :: binary>>, sum) do
    _checksum_xor(rest, Bitwise.bxor(val, sum))
  end
end
