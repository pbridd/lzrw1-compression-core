import argparse
import VectorGenerator
import os

def main():
    parser = argparse.ArgumentParser(description = "process arguments")
    parser.add_argument("--num_chars", "-nc", default=256, help="defines the number of "
                                                                "characters to use for this run of the"
                                                                " vector generator")
    parser.add_argument("--num_vectors", "-nv", default=100, help="defines the number of vectors to generate")
    parser.add_argument("--manual_tv", "-mtv", default="manual_tvs.txt",
                        help= "defines where to find manual test decompressed testbench strings, 1 line per tv")

    parser.add_argument("--io_path", "-io", default = "", help="Defines where this program will search for and output test vectors")

    args = parser.parse_args()

    num_chars = int(args.num_chars)
    num_vectors = int(args.num_vectors)
    manual_vector_filename = args.manual_tv
    io_path = args.io_path

    i = 0
    while i < num_vectors:
        gen = VectorGenerator.VectorGenerator()
        print("Current testvector: " + str(i))
        gen.generatevectors(num_chars, os.path.join(io_path, "generated_tv_" + str(i)), 15)
        i += 1

    # generate manual tvs
    curr_file = 0
    with open(os.path.join(io_path,manual_vector_filename), 'r') as manual_vector_file:
        for line in manual_vector_file:
            generate_manual_testvector(line.replace('\n', '').replace('\r', ''), os.path.join(io_path,"manual_tv_" + str(curr_file)), 15)
            curr_file += 1




def generate_manual_testvector(in_string, out_file_prefix, max_length):
    gen = VectorGenerator.VectorGenerator()
    compressed_string = gen.compress_string(in_string, max_length)
    gen.write_out_binary_data(compressed_string, in_string, out_file_prefix)

if __name__ == "__main__":
    main()