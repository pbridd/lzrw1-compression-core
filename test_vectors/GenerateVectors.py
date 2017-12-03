import argparse
import VectorGenerator

def main():
    #test
    print("not yet implemented")
    parser = argparse.ArgumentParser(description = "process arguments")
    parser.add_argument("--num_chars", "-nc", default=256, help="defines the number of "
                                                                "characters to use for this run of the"
                                                                " vector generator")
    parser.add_argument("--num_vectors", "-nv", default=10, help="defines the number of vectors to generate")

    args = parser.parse_args()

    num_chars = args.num_chars
    num_vectors = args.num_vectors

    i = 0
    while i < num_vectors:
        gen = VectorGenerator.VectorGenerator()
        print("Current testvector: " + str(i))
        gen.generatevectors(num_chars, "generated_tv_" + str(i), 15)
        i += 1

if __name__ == "__main__":
    main()