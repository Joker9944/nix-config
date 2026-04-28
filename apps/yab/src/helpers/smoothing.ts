export function movingAverage(n = 5): (x: number) => number {
	const buffer: number[] = []

	return (x: number): number => {
		buffer.push(x)
		if (buffer.length > n) buffer.shift()
		const sum = buffer.reduce((a, b) => a + b)
		return sum / buffer.length
	}
}

export function exponentialMovingAverage({ alpha = 0.3, initial }: { alpha?: number; initial?: number } = {}): (
	x: number,
) => number {
	let ema: number
	let compute: (x: number) => number

	const steady = (x: number) => (ema = alpha * x + (1 - alpha) * ema)

	if (initial !== undefined) {
		ema = initial
		compute = steady
	} else {
		compute = (x) => {
			ema = x
			compute = steady
			return ema
		}
	}

	return (x) => compute(x)
}
