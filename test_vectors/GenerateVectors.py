import argparse
import VectorGenerator

def main():
    parser = argparse.ArgumentParser(description = "process arguments")
    parser.add_argument("--num_chars", "-nc", default=256, help="defines the number of "
                                                                "characters to use for this run of the"
                                                                " vector generator")
    parser.add_argument("--num_vectors", "-nv", default=10, help="defines the number of vectors to generate")
    parser.add_argument("--manual_tv", "-mtv", default="manual_tvs.txt", type=argparse.FileType('r'),
                        help= "defines where to find manual test decompressed testbench strings, 1 line per tv")

    args = parser.parse_args()

    num_chars = args.num_chars
    num_vectors = args.num_vectors
    manual_vector_file = args.manual_tv

    i = 0
    while i < num_vectors:
        gen = VectorGenerator.VectorGenerator()
        print("Current testvector: " + str(i))
        gen.generatevectors(num_chars, "generated_tv_" + str(i), 15)
        i += 1

    # generate manual tvs
    curr_file = 0
    for line in manual_vector_file:
        generate_manual_testvector(line, "manual_tv_" + str(curr_file), 15)




def generate_manual_testvector(in_string, out_file_prefix, max_length):
    gen = VectorGenerator.VectorGenerator()
    compressed_string = gen.compress_string(in_string, max_length)
    gen.write_out_binary_data(compressed_string, in_string, out_file_prefix)

if __name__ == "__main__":
    main()