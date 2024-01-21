# Identifying Ideal Lattice

  

This Python script implements algorithms for identifying ideal lattices using incomplete Hermite normal form (IHN-F), complete factorization and partial Hermite normal form (CFP-IHNF), and complete factorization and partial order ideal Hermite normal form (CFP-OIHN-F). Additionally, it includes a procedure for identifying ideal lattices using determinant lifting (DL).

  

## Usage

### Environmen

Make sure you have SageMath version 9.8 installed in your runtime environment. You can find the download link on the official SageMath website: https://www.sagemath.org/download.html


### Dependencies

The script requires the following Python libraries:

- `time`: For measuring time.

- `logging`: For logging information and warnings.

- `csv`: For handling CSV file operations.

- `sage.matrix.matrix_integer_dense_hnf`: For Hermite Normal Form computation.

Make sure to have SageMath installed, as it provides the necessary library for the Hermite Normal Form computation.

#### Logging

Logging is configured to write messages to a file named `identifying_ideal_lattice.log`. The logging level is set to `WARN` to capture warning messages and errors.

### Main Function

The `main` function is the entry point of the script, and it takes three parameters:

1. `dim`: Dimension of the lattice.

2. `bound`: Bound for generating lattice elements.

3. `experiment_num`: Number of experiments to conduct.

#### Example Usage

```python

if __name__ == "__main__":

	# Set the parameters
	dim, bound, experiment_num = 3, 10, 10
	main(dim, bound, experiment_num)

```

#### Input

- `dim`: Integer representing the dimension of the lattice.

- `bound`: Integer specifying the bound for generating lattice elements.

- `experiment_num`: Integer indicating the number of experiments to conduct.

#### Output

The `main` function conducts experiments to identify ideal lattices using various methods and measures the time taken for each method. The results are then saved to a CSV file, and summary statistics are printed to the console

- **CSV Output**: A CSV file is generated with the following columns:

	- `seed`: Seed used for lattice generation.
	
	- `cfp_ihnf_result`: Result of identifying ideal lattice using CFP-IHNF.
	
	- `cfp_oihnf_result`: Result of identifying ideal lattice using CFP-OIHN-F.
	
	- `dl_result`: Result of identifying ideal lattice using DL.
	
	- `cfp_ihnf_time`: Time taken by CFP-IHNF method.
	
	- `cfp_oihnf_time`: Time taken by CFP-OIHN-F method.
	
	- `dl_time`: Time taken by DL method.

- **Console Output**: Summary statistics are printed to the console:

	- `CSV file '<filename>' has been created.`
	
	- `Already completed <experiment_num> experiments.`
	
	- `The average time taken by identifying_ideal_cfp_ihnf is <average_time> seconds.`
	
	- `The average time taken by identifying_ideal_cfp_oihnf is <average_time> seconds.`
	
	- `The average time taken by identifying_ideal_dl is <average_time> seconds.`

## Additional Choice

### Debug

You can enable debugging by setting `logging.basicConfig(filename='identifying_ideal_lattice.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')` in your code.


### Method Parameter

#### Method `identifying_ideal_cfp`

The `method` parameter in the `identifying_ideal_cfp` function determines the specific algorithm to use for identifying ideal lattices. It can take three values:

- `'ihnf'`: Incomplete Hermite Normal Form.

- `'oihnf'`: Complete Factorization and Partial Order Ideal Hermite Normal Form.


```python

def identifying_ideal_cfp(self, input_matrix, method='ihnf'):

# Code for identifying ideal lattice using the specified method

```

##### Example for `identifying_ideal_cfp`

```python
# Example using 'ihnf' method
result = identifying_lattice.identifying_ideal_cfp(lattice_matrix, method='ihnf')
# Example using 'oihnf' method
result = identifying_lattice.identifying_ideal_cfp(reverse_matrix4oihnf, method='oihnf')
```
#### Method `identifying_ideal_dl`

"identifying_ideal_dl" is divided into two parts: the first part, "identifying_ideal_dl1," involves applying the Hermite Normal Form (HNF) to the input matrix and performing some preprocessing operations without recording time. The second part, "identifying_ideal_dl2," has three parameters corresponding to three different methods for calculating the adjugate matrix.

The `method` parameter in the `identifying_ideal_dl` function determines the specific algorithm to calculate adjugate matrix. It can take three values:

```python
# Example using 'inverse' method
Result = identifying_lattice. Identifying_ideal_dl2 (matrix, method='inverse')

# Example using 'sage' method
Result = identifying_lattice. Identifying_ideal_dl2 (matrix, method='sage')

# Example using 'dl' method
Result = identifying_lattice. Identifying_ideal_dl2 (matrix, method='dl')
```

### Author

You can find more information on [my personal website](www.fffmath.com).

### License

This script is released under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.