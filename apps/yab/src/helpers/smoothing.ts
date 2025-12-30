export function movingAverage(n = 5): (x: number) => number {
	const buffer: number[] = []

	return (x: number): number => {
		buffer.push(x)
		if (buffer.length >= n) buffer.shift()
		const sum = buffer.reduce((a, b) => a + b)
		return sum / buffer.length
	}
}
