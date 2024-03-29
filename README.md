# Identifying Ideal Lattice

  

This Python script implements algorithms for identifying ideal lattices using Incomplete Hermite normal form (ihnf) and Optimal Incomplete Hermite normal form (oihnf).More details can be found in our paper [here](https://arxiv.org/abs/2307.12497). Additionally, it includes an algorithm called identity_ideal_dl for identifying ideal lattices using algorithm in [[DL07]](https://eprint.iacr.org/2007/322).

  

## Usage

Usage: sage identifying_ideal_lattice.sage `<dim>` `<bound>` `<experiment_num>`

##### Example Usage

```bash

# Run experiments 10 times with dimensions set to 3 and a bound of 2^10.

sage identifying_ideal_lattice.sage 3 10 10

```
Or, you can use the Bash script if you want to obtain experimental results under different parameters at once. All you need to do is add the target parameters in the run_experiments.sh. Then, you can get an output.txt as the output.

```bash

# If you haven't modified the run_experiments.sh script, it will run experiments under each set of parameters (dim, bound, experiment_num) equal to (3, 5, 5) and (3, 10, 5).
bash run_experiments.sh

```
### Environment

Make sure you have SageMath version 9.8 installed in your runtime environment. You can find the download link on the official SageMath website: https://www.sagemath.org/download.html


### Dependencies

The script requires the following Python libraries:

- `time`: For measuring time.

- `logging`: For logging information and warnings.

- `csv`: For handling CSV file operations.

- `sage.matrix.matrix_integer_dense_hnf`: For Hermite Normal Form computation.

Make sure to have SageMath installed, as it provides the necessary library for the Hermite Normal Form computation.

### Input

- `dim`: Integer representing the dimension of the lattice.

- `bound`: Integer specifying the bound for generating lattice elements.

- `experiment_num`: Integer indicating the number of experiments to conduct.


### Output

The `main` function conducts experiments to identify ideal lattices using various methods and measures the time taken for each method. The results are then saved to a CSV file, and summary statistics are printed to the console

- **CSV Output**: A CSV file is generated with the following columns:

	- `seed`: Seed used for lattice generation.
	
    - `cfp_result`: Result of identifying an ideal lattice using CFP. If the input matrix can be viewed as an ideal lattice, then this algorithm will output a tuple: `（True, (a polynomial, a basis matrix))`. If it is not an ideal lattice, the result will be `(False, None)`.

    - `dl_result`: Result of identifying an ideal lattice using DL. If the input matrix can be viewed as an ideal lattice, then this algorithm will output `(True, a polynomial)`. If it is not an ideal lattice, the result will be `(False, None)`.
        
	- `cfp_time`: Time taken by CFP method.
		
	- `dl_time`: Time taken by DL method.

- **Console Output**: Summary statistics are printed to the console:

	- `CSV file '<filename>' has been created.`
	
	- `Already completed <experiment_num> experiments.`
	
	- `The average time taken by identifying_ideal_cfp is <average_time> seconds.`
		
	- `The average time taken by identifying_ideal_dl is <average_time> seconds.`

## Additional Choice

You can choose to modify the "identifying_ideal_lattice.sage" to customize the results according to your preferences.

### Debug

You can enable debugging by setting `logging.basicConfig(filename='identifying_ideal_lattice.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')` in your code.

##### Example Usage

```python

# Set up log configuration
logging.basicConfig(filename='identifying_ideal_lattice.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

```

### Method Parameter

If you want the generated lattice to be an ideal lattice, or if you wish to employ alternative methods from CFP, or use different approaches to generate adjugate matrices in the DL algorithm, you can choose to modify the code at the end of the file.

##### Example Usage

```python

if __name__ == "__main__":
    # Check if command-line arguments are provided
    if len(sys.argv) != 4:
        print("Usage: sage identifying_ideal_lattice.sage <dim> <bound> <experiment_num>")
        sys.exit(1)

    # Parse command-line arguments
    dim, bound, experiment_num = map(int, sys.argv[1:])

    # Set other parameters as needed (e.g., dl_method)
    # 'lattice' or 'ideal_lattice'
    generate_method = 'lattice'
    # 'ihnf' or 'oihnf'
    cfp_method = 'ihnf'
    # 'inverse', 'sage', or 'dl'
    dl_method = 'inverse'

    # Run the main function with the provided arguments
    main(dim, bound, experiment_num, generate_method=generate_method, cfp_method=cfp_method, dl_method=dl_method)

```


#### Method `generate_method`

Generate lattice for random integers if method is set to "lattice", or generate ideal lattice for randomly chosen polynomials f and g if method is set to "ideal_lattice". The ideal lattice is based on the principal ideal generated by g in Z[x]/f(x) under coefficient embedding.

#### Method `cfp_method`

The `method` parameter in the `identifying_ideal_cfp` function determines the specific algorithm to use for identifying ideal lattices. It can take two values:

- `'ihnf'`: Incomplete Hermite Normal Form.

- `'oihnf'`: Complete Factorization and Partial Order Ideal Hermite Normal Form.

##### Related Code
```python

def identifying_ideal_cfp(self, input_matrix, method='ihnf'):

```
#### Method `dl_method`

"identifying_ideal_dl" is divided into two parts: the first part, "identifying_ideal_dl1," involves applying the Hermite Normal Form (HNF) to the input matrix and performing some preprocessing operations without recording time. The second part, "identifying_ideal_dl2," has three parameters corresponding to three different methods for calculating the adjugate matrix.

The `method` parameter in the `identifying_ideal_dl` function determines the specific algorithm to calculate adjugate matrix. It can take three values:

##### Related Code
```python

def identifying_ideal_dl2(self, input_matrix, method='inverse'):

```

### Author

You can find more information on [my personal website](https://www.fffmath.com/).

### License

This script is released under the MIT License 2.0. See the [LICENSE](LICENSE) file for details.
