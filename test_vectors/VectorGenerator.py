import argparse
import random
import string
import sys



class VectorGenerator:

    def generatevectors(self, num_chars, vector_name, max_match_length):

        random_string = self.generate_string(num_chars)
        compressed_string = self.compress_string(random_string, max_match_length)
        self.write_out_binary_data(compressed_string, random_string, vector_name)


    def write_out_binary_data(self, compressed_data, decompressed_data, vector_name):
        """
        This writes the data passed in out into a file
        :param compressed_data: a list of CompressedData objects
        :param decompressed_data: a string
        :param vector_name: What to name this test vector
        :return: 0 if successful, nonzero if not
        """
        with open (vector_name + "_d.bin", 'wb') as decompressed_file:
            decompressed_file.write(bytearray(decompressed_data, 'ascii'))

        # process the binary data
        with open (vector_name + "_c.bin", 'wb') as compressed_file:
            for cdata in compressed_data:
                if cdata.get_binary_control_word() == 1:
                    c_bytes = cdata.get_binary_compressed_data().to_bytes(2, byteorder='big', signed=False)
                else:
                    c_bytes = cdata.get_binary_compressed_data().to_bytes(1, byteorder='big', signed=False)
                compressed_file.write(c_bytes)

        with open (vector_name + "_cw.bin", 'wb') as control_word_file:
            temp_count = 0
            temp_data = 0
            for cdata in compressed_data:
                temp_data = (temp_data << 1) | cdata.get_binary_control_word()
                if temp_count == 31:
                    control_word_file.write(temp_data.to_bytes(4, 'big'))
                    temp_count = 0
                    temp_data = 0
                else:
                    temp_count += 1
            # perform final write-out
            if temp_count > 0:
                temp_data << 31 - temp_count
                control_word_file.write(temp_data.to_bytes(4, 'big'))



    def compress_string(self, string_to_compress, max_match_length):
        """
        compresses the string that has been passed in using an adaptation of the LZRW1 algorithm
        :param string_to_compress: The string we want to compress
        :return: a list of CompressedData objects
        """

        history_array = []
        full_char_array = []
        hash_table = dict()

        current_array_index = 0

        #populate full char array
        for char in string_to_compress:
            full_char_array.append(char)
        i = 0
        # iterate through all three char pairs and compress them
        while i < len(string_to_compress):
            key = string_to_compress[i:i+3]
            curr_control_word = 0
            temp_index = -1
            offset = -1
            length = -1
            literal = -1

            # look up key and update if necessary
            if key in hash_table and i < len(string_to_compress) - 2:
                temp_raw_index = hash_table[key][0]
                temp_array_index = hash_table[key][1]
                hash_table[key] = (i, current_array_index)
                curr_control_word = 1
                offset = i - temp_raw_index

                last_match_idx = min(len(string_to_compress), i + max_match_length)
                length = self.get_length_of_match(string_to_compress[i:last_match_idx], temp_raw_index, max_match_length, full_char_array)
                print("compressed string " + string_to_compress[i:i+length])
                # re-assign i to match `the new length
                i = i + length
                current_array_index += 1

            else:
                literal = string_to_compress[i]
                hash_table[key] = (i, current_array_index)
                current_array_index += 1
                i = i + 1

            # construct compressed data entry
            temp_compr = CompressedData(curr_control_word, length, offset, literal)
            history_array.append(temp_compr)

        return history_array

    def get_length_of_match(self, string_to_match, initial_raw_index, max_match_length, full_char_array):
        """
        Get the length of the match
        :param string_to_match: the string to match
        :return: the length of the match
        """
        current_index = initial_raw_index

        match_length = 0
        for char in string_to_match:
            array_char = full_char_array[current_index]
            if char == array_char:
                match_length += 1
                current_index += 1
            else:
                assert(match_length >= 3)
                return match_length

        assert(match_length >= 3)
        return match_length




    def generate_string(self, num_chars):
        """
        Generates a test vector string with the specified number of chars
        :param num_chars: the number of chars to make the string
        :return: a string with random characters
        """

        # only one method of random string generation has been implemented
        return self.generate_alphanumeric_random_string(num_chars)


    def generate_alphanumeric_random_string(self, num_chars):
        """
        Generates a pure random string only using alphanumeric characters. Is not good
        for simulating natural language text (compression will not be as good)
        :param num_chars: the number of characters to return
        :return: a randomly generated alphanumeric string
        """

        ret_string = ''.join(random.choice(string.ascii_lowercase) for _ in range(num_chars))
        return ret_string


class CompressedData:
    LENGTH_MASK = 0b00000000000000001111000000000000
    OFFSET_MASK = 0b00000000000000000000111111111111
    def __init__(self, control_word, length, offset, literal):
        self.control_word = control_word
        self.length = length
        self.offset = offset
        self.literal = literal

    def get_bit_tuple(self):
        return tuple(bin(self.control_word), bin(self.length).join(bin(self.offset)))

    def get_binary_compressed_data(self):
        if self.control_word == 1:
            #todo process the compressed data
            binary_data = ((self.length << 12) & self.LENGTH_MASK) | (self.offset & self.OFFSET_MASK)
            return binary_data
        else:
            return bytearray(self.literal, 'ascii')[0]

    def get_binary_control_word(self):
        if self.control_word == 0 :
            return 0b0
        else:
            return 0b1