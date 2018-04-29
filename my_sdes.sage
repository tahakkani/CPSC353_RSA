# Sbox definitions
s0 = ([[1, 0, 3, 2],
      [3, 2, 1, 0],
      [0, 2, 1, 3],
      [3, 1, 3, 2]])

s1 = ([[0, 1, 2, 3],
      [2, 0, 1, 3],
      [3, 0, 1, 0],
      [2, 1, 0, 3]])        

def encrypt(m, k):
    pass
    
def decrypt(c, k):
    pass

# Helper functions to use in the cipher blockchaining
# m is cipher message, k0 k1 are keys
def cipher_blockchain(m,k0,k1):


# Perform SDES encryption on one 8-bit element
def _encrypt_single(x, k0, k1):
  l = x[0:5]
  r = x[5:8]

  feistel1 = _feistal(k0,r)

  l_next = []
  for i in range(4):
    l_next.append(r[i] ^ feistel1[i])

  r_next = r

  feistel2 = _feistal(k1,r_next)

  l_final = []
  for i in range(4):
    l_final.append(r_next[i] ^ feistel2[i])

  r_final = r_next

  return l_final + r_final

# Perform SDES decryption on one 8-bit element
def _decrypt_single(y, k0, k1):
  l = y[0:5]
  r = y[5:8]

  feistel1 = _feistal(k1, r)

  l_next = []
  for i in range(5):
    l_next.append(r[i] ^ feistel1[i])

  r_next = r

  feistel2 = _feistal(k0, r_next)
  l_final = []
  for i in range(5):
    l_final.append(r_next[i] ^ feistel2[i])

  r_final = r_next

  return l_final + r_final


    pass

def _permute(pt):
  permuted = []
  permuted.append(pt[1])
  permuted.append(pt[5])
  permuted.append(pt[2])
  permuted.append(pt[0])
  permuted.append(pt[3])
  permuted.append(pt[7])
  permuted.append(pt[4])
  permuted.append(pt[6])
  return permuted

def _inv_permute(ct):
  permuted = []
  permuted.append(ct[3])
  permuted.append(ct[0])
  permuted.append(ct[2])
  permuted.append(ct[4])
  permuted.append(ct[6])
  permuted.append(ct[1])
  permuted.append(ct[7])
  permuted.append(ct[5])
  return permuted

# Pass in 8-bits, and 4-bits respectively
def _feistal(key, r):
    n = ([[r[3],r[0],r[1],r[2]], 
        [r[1],r[2],r[3],r[0]]])
    k = ([[key[0],key[1],key[2],key[3]],
          [key[4],key[5],key[6],key[7]]])
    p = ([[n[0][0] ^ k[0][0]], [n[0][1] ^ k[0][1]], [n[0][2] ^ k[0][2]], [n[0][3] ^ k[0][3]],
          [n[1][0] ^ k[1][0]], [n[1][1] ^ k[1][1]], [n[1][2] ^ k[1][2]], [n[1][3] ^ k[1][3]]])

    first_bits = [p[0][0], p[0][3]]
    first_out = frombits(first_bits)
    secont_bits = [p[0][1], p[0][2]]
    second_out = frombits(second_bits)
    s_0 = s0[first_out][second_out]

    first_bits = [p[1][0], p[1][3]]
    first_out = frombits(first_bits)
    second_bits = [p[1][1], p[1][2]]
    second_out = frombits(second_bits)
    s_1 = s1[first_out][second_out]


    s_0_bits = tobits(s_0)
    s_1_bits = tobits(s_1)

    s_combined = s_0_bits + s_1_bits
    return [s_combined[1],s_combined[3],s_combined[2],s_combined[0]]


# May not be neccessary
def _inv_feistal(x, k):
    pass

def _generate_keys(k10):
    # Convert key to bits and truncate 
    key = format(key, '#012b')[2:]
    # Create array of bits for 10 bit key
    key_b = [int(digit) for digit in key]

    # Follow initial permutation
    p10 = [2, 4, 1, 6, 3, 9, 0, 8, 7, 5]
    key_perm = [0] * 10
    for i in range(10):
        key_perm[i] = key_b[p10[i]]
    
    # Create key 0 and key 1
    k0 = list(key_perm)
    k1 = list(key_perm)

    # Rotate bits of key 0 left
    k0[0:5] = k0[1:5] + [k0[0]]
    k0[5:10] = k0[6:10] + [k0[5]]

    # Rotate bits of key 0 left twice to get key 1
    k1[0:5] = k0[2:5] + k0[0:2]
    k1[5:10] = k0[7:10] + k0[5:7]

    # Follow second permutation
    p8 = [5, 2, 6, 3, 7, 4, 9, 8]
    k0p = [0] * 8 # Permuted keys
    k1p = [0] * 8
    for i in range(8):
        k0p[i] = k0[p8[i]]
        k1p[i] = k1[p8[i]]

def tobits(num):
    # Convert num to bits and truncate "0b" header
    num = format(num, '#010b')[2:]
    # Convert from bit string to integer list
    return [int(digit) for digit in num]

def frombits(bits):
    num = 0
    for i in range(len(bits)):
        if bits[-i] == 1:
            num = num + 2 ^ (i-1) 
    return num


#msg_in is a string
def txt_to_num(msg_in):      
  #transforms string to the indices of each letter in the 8-bit ASCII table
  msg_idx = map(ord,msg_in)
  #computes the base 256 integer formed from the indices transformed to decimal.
  #each digit in the list is multiplied by the respective power of 256 from
  #right to left.  For example, [64,64] = 256^1 * 64 + 256^0 * 64
  num = ZZ(msg_idx,256)
  return num 

#Converts a digit sequence to a string
#Return the string

#num_in is a decimal integer composed as described above 
def num_to_txt(num_in):
  #returns the list described above 
  msg_idx = num_in.digits(256)
  #maps each index to its associated character in the ascii table 
  m = map(chr,msg_idx)
  print m
  #transforms the list to a string
  m = ''.join(m)
  return m
  
