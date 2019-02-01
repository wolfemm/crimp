# frozen_string_literal: true

require 'spec_helper'

describe '.signature' do
  it 'will return an md5 hash' do
    expect(Crimp.signature('a')).to eq 'd132c0567a5964930f9ee5f14e779e32'
  end

  it 'will return a sha1 hash when instructed to' do
    expect(Crimp.signature('a', Digest::SHA1)).to eq '1e4b66abe83a478d0e271bede40afd89c9519134'
  end

  it 'will return a sha2 hash when instructed to' do
    expect(Crimp.signature('a', Digest::SHA2)).to eq '81c99b3df1d89a5d4cc5bdbd8b90f3ec39e448164f410d1884811405e4247dca'
  end

  it 'will return a sha512 hash when instructed to' do
    expect(Crimp.signature('a', Digest::SHA512)).to eq 'b075959d199f0c84323ea8449e1a8c860894a328f0ecddf9d1be1576e8f2d288564309df4dc3677ae8a18df63f28a544bb6e9f8592633c6c42035d526ffecddc'
  end
end

describe '.notation' do
  it 'returns a string representation of the passed data' do
    expect(Crimp.notation([123, 'abc'])).to eq('123NabcSA')
  end
end

describe '.annotate' do
  it 'returns an array of tuples representing the value and the type' do
    expect(Crimp.annotate([123, 'abc'])).to eq([[[123, 'N'], ['abc', 'S']], 'A'])
  end

  it "returns a tuple [val, 'N'] for numeric primitives" do
    expect(Crimp.annotate(123)).to eq([123, 'N'])
  end

  it "returns a tuple [val, 'S'] for string primitives" do
    expect(Crimp.annotate('abc')).to eq(['abc', 'S'])
  end

  it "returns a tuple [[], 'A'] for empty arrays" do
    expect(Crimp.annotate([])).to eq([[], 'A'])
  end
end

describe 'Strings' do
  it 'handles strings' do
    expect(Crimp.annotate('a')).to eq(['a', 'S'])
  end

  it 'handles capitalised strings with no modifications' do
    expect(Crimp.annotate('A')).to eq(['A', 'S'])
  end

  it 'handles utf-8 strings' do
    expect(Crimp.annotate('å')).to eq(['å', 'S'])
  end

  it 'treats symbols like strings' do
    expect(Crimp.annotate(:a)).to eq(['a', 'S'])
  end

  it 'treats empty strings like strings' do
    expect(Crimp.annotate('')).to eq(['', 'S'])
  end
end

describe 'Numbers' do
  it 'handles integers' do
    expect(Crimp.annotate(1)).to eq([1, 'N'])
  end

  it 'handles floats' do
    expect(Crimp.annotate(3.14)).to eq([3.14, 'N'])
  end

  it 'handles bignums' do
    bignum = 10_000_000_000_000_000_000

    expect(Crimp.annotate(bignum)).to eq([bignum, 'N'])
  end
end

describe 'Nils' do
  it 'handles nils' do
    expect(Crimp.annotate(nil)).to eq([nil, '_'])
  end
end

describe 'Booleans' do
  it 'handles falsey values' do
    expect(Crimp.annotate(false)).to eq([false, 'B'])
  end

  it 'handles truthy values' do
    expect(Crimp.annotate(true)).to eq([true, 'B'])
  end
end

describe 'Arrays' do
  it 'handles arrays as collection of primitives' do
    expect(Crimp.annotate([1, 2])).to eq([[[1, 'N'], [2, 'N']], 'A'])
  end

  it 'sorts arrays' do
    expect(Crimp.annotate([2, 1])).to eq([[[1, 'N'], [2, 'N']], 'A'])
  end

  it 'returns the same signature for two arrays containing the same (unordered) values' do
    arr1 = [1, 2, 3]
    arr2 = [2, 1, 3]

    expect(Crimp.signature(arr1)).to eq(Crimp.signature(arr2))
  end

  it 'does not return the same signature for two arrays containing different values' do
    arr1 = [1, 2, 3]
    arr2 = ['1', '2', '3']

    expect(Crimp.signature(arr1)).to_not eq(Crimp.signature(arr2))
  end

  it 'sorts an array with mixed strings and symbols' do
    expect(Crimp.notation(["b", :a, "c"])).to eq 'aSbScSA'
  end
end

describe 'Nested Arrays' do
  it 'sorts arrays with a single nested array' do
    expect(Crimp.notation([3, [4, 2], 1])).to eq('1N3N2N4NAA')
  end

  it 'sorts arrays with a multiple nested arrays' do
    expect(Crimp.notation([3, [4, 2], 1, [6, 5]])).to eq('1N3N2N4NA5N6NAA')
  end
end

describe 'Hashes' do
  it 'handles hashes as collection of primitives' do
    expected = [
      [
        [
          [
            ['a', 'S'],
            ['b', 'S']
          ],
          'A'
        ]
      ],
      'H'
    ]

    expect(Crimp.annotate({a: 'b'})).to eq(expected)
  end

  it 'sorts hashes by key and then sorts the resulting pair of tuples' do
    expected = [
      [
        [
          [
            [1, 'N'],
            ['e', 'S']
          ],
          'A'
        ],
        [
          [
            ['a', 'S'],
            ['b', 'S']
          ],
          'A'
        ],
        [
          [
            ['c', 'S'],
            ['f', 'S']
          ],
          'A'
        ]
      ],
      'H'
    ]

    expect(Crimp.annotate({ a: 'b', f: 'c', 'e' => 1 })).to eq(expected)
  end

  it 'returns the same signature for two hashes containing the same (unordered) values' do
    hsh1 = { a: 2, b: 1 }
    hsh2 = { b: 1, a: 2 }

    expect(Crimp.signature(hsh1)).to eq(Crimp.signature(hsh2))
  end

  it 'does not return the same signature for two hashes containing the different values' do
    hsh1 = { a: 1, b: 2 }
    hsh2 = { a: 2, b: 1 }

    expect(Crimp.signature(hsh1)).to_not eq(Crimp.signature(hsh2))
  end

  it 'sorts an hash with mixed key types' do
    expect(Crimp.notation({:b => "c", "d" => "a"})).to eq 'aSdSAbScSAH'
  end
end

describe 'Sets' do
  it 'handles sets as arrays' do
    expect(Crimp.annotate(Set.new([1, 2]))).to eq([[[1, 'N'], [2, 'N']], 'A'])
  end

  it 'produces the same signature for Array Sets and Arrays' do
    expect(Crimp.signature(Set.new([1, 2]))).to eq(Crimp.signature([2, 1]))
  end

  it 'handles Hash sets as arrays' do
    expect(Crimp.annotate(Set.new({ 1 => 2 }))).to eq([[[[[1, "N"], [2, "N"]], "A"]], "A"])
  end

  it 'does NOT produce the same signature for Hash Sets and Hashes' do
    expect(Crimp.signature(Set.new({ 1 => 2 }))).to_not eq(Crimp.signature({ 1 => 2 }))
  end

  it 'sorts sets as arrays' do
    expect(Crimp.annotate(Set.new([2, 1]))).to eq([[[1, 'N'], [2, 'N']], 'A'])
  end
end

describe 'nested data structures' do
  it 'handles a hash with nested arrays and hashes' do
    obj = { a: [1, 2], b: { c: 'd' } }

    expected = [
      [
        [
          [
            [
              [
                [1, 'N'],
                [2, 'N']
              ],
              'A'
            ],
            ['a', 'S']
          ],
          'A'
        ],
        [
          [
            ['b', 'S'],
            [
              [
                [
                  [
                    ['c', 'S'],
                    ['d', 'S']
                  ],
                  'A']
              ],
              'H']
          ],
          'A']
      ],
      'H'
    ]

    expect(Crimp.annotate(obj)).to eq(expected)
  end

  it 'handles an array of hashes' do
    obj = [{ a: 1 }, { b: 2 }]
    expected= [
      [
        [
          [
            [
              [
                [1, 'N'],
                ['a', 'S']
              ],
              'A'
            ]
          ],
          'H'
        ],
        [
          [
            [
              [
                [2, 'N'],
                ['b', 'S']
              ],
              'A'
            ]
          ],
          'H'
        ]
      ],
      'A'
    ]

    expect(Crimp.annotate(obj)).to eq(expected)
  end
end

describe 'Objects' do
  it 'raise an error if not in the list of allowed primitives' do
    expect { Crimp.signature(Object.new) }
      .to raise_error(TypeError, 'Expected a (String|Number|Boolean|Nil|Hash|Array), Got Object.')
  end
end
