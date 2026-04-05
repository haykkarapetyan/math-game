package puzzle

import (
	"encoding/json"
	"math/rand"
)

type LevelConfig struct {
	MinNum       int
	MaxNum       int
	Ops          []string
	BlankCount   int
	TimeLimitSec int
}

// GetLevelConfig returns the puzzle config for a given level number (1-10)
func GetLevelConfig(levelNum int) LevelConfig {
	configs := map[int]LevelConfig{
		1:  {MinNum: 1, MaxNum: 5, Ops: []string{"+"}, BlankCount: 1, TimeLimitSec: 30},
		2:  {MinNum: 1, MaxNum: 6, Ops: []string{"+"}, BlankCount: 2, TimeLimitSec: 45},
		3:  {MinNum: 1, MaxNum: 7, Ops: []string{"+"}, BlankCount: 3, TimeLimitSec: 60},
		4:  {MinNum: 1, MaxNum: 8, Ops: []string{"+"}, BlankCount: 4, TimeLimitSec: 75},
		5:  {MinNum: 1, MaxNum: 9, Ops: []string{"+"}, BlankCount: 5, TimeLimitSec: 90},
		6:  {MinNum: 2, MaxNum: 12, Ops: []string{"+", "-"}, BlankCount: 5, TimeLimitSec: 90},
		7:  {MinNum: 1, MaxNum: 9, Ops: []string{"+", "-"}, BlankCount: 6, TimeLimitSec: 105},
		8:  {MinNum: 2, MaxNum: 12, Ops: []string{"+", "-"}, BlankCount: 6, TimeLimitSec: 105},
		9:  {MinNum: 1, MaxNum: 12, Ops: []string{"+", "-"}, BlankCount: 7, TimeLimitSec: 120},
		10: {MinNum: 1, MaxNum: 9, Ops: []string{"+", "-", "*"}, BlankCount: 8, TimeLimitSec: 120},
	}
	if c, ok := configs[levelNum]; ok {
		return c
	}
	return LevelConfig{MinNum: 1, MaxNum: 12, Ops: []string{"+", "-", "*"}, BlankCount: 4, TimeLimitSec: 90}
}

type CellData struct {
	Row   int    `json:"row"`
	Col   int    `json:"col"`
	Type  string `json:"type"`
	Value any    `json:"value"`
	Given bool   `json:"given"`
}

type PuzzleData struct {
	GridRows     int        `json:"grid_rows"`
	GridCols     int        `json:"grid_cols"`
	Cells        []CellData `json:"cells"`
	NumberPool   []int      `json:"number_pool"`
	TimeLimitSec int        `json:"time_limit_sec"`
	HintCount    int        `json:"hint_count"`
}

type AnswerCellData struct {
	Row   int `json:"row"`
	Col   int `json:"col"`
	Value int `json:"value"`
}

type PuzzleAnswer struct {
	Cells []AnswerCellData `json:"cells"`
}

type GeneratedPuzzle struct {
	Data         json.RawMessage
	Answer       json.RawMessage
	TimeLimitSec int
}

// Generate creates a valid 2x2 crossword puzzle
func Generate(config LevelConfig) *GeneratedPuzzle {
	for attempt := 0; attempt < 5000; attempt++ {
		if p := tryGenerate(config); p != nil {
			return p
		}
	}
	// Should never reach here with reasonable configs
	return nil
}

func tryGenerate(config LevelConfig) *GeneratedPuzzle {
	rng := rand.New(rand.NewSource(rand.Int63()))

	op1 := config.Ops[rng.Intn(len(config.Ops))]
	op2 := config.Ops[rng.Intn(len(config.Ops))]
	op3 := config.Ops[rng.Intn(len(config.Ops))]
	op4 := config.Ops[rng.Intn(len(config.Ops))]

	a := randNum(rng, config)
	b := randNum(rng, config)
	c := randNum(rng, config)
	d := randNum(rng, config)

	r1 := eval(a, op1, b)
	r2 := eval(c, op2, d)
	r3 := eval(a, op3, c)
	r4 := eval(b, op4, d)

	if r1 == nil || r2 == nil || r3 == nil || r4 == nil {
		return nil
	}
	if *r1 < 0 || *r2 < 0 || *r3 < 0 || *r4 < 0 {
		return nil
	}
	if *r1 > 99 || *r2 > 99 || *r3 > 99 || *r4 > 99 {
		return nil
	}
	if a == b && b == c && c == d {
		return nil
	}

	values := []int{a, b, c, d, *r1, *r2, *r3, *r4}
	posKeys := [][2]int{{0, 0}, {0, 2}, {2, 0}, {2, 2}, {0, 4}, {2, 4}, {4, 0}, {4, 2}}

	// Pick blank positions
	positions := []int{0, 1, 2, 3, 4, 5, 6, 7}
	rng.Shuffle(len(positions), func(i, j int) { positions[i], positions[j] = positions[j], positions[i] })
	blankPositions := make(map[int]bool)
	for i := 0; i < config.BlankCount && i < len(positions); i++ {
		blankPositions[positions[i]] = true
	}

	// Build cells
	cells := []CellData{
		numCell(0, 0, a, !blankPositions[0]),
		opCell(0, 1, op1),
		numCell(0, 2, b, !blankPositions[1]),
		eqCell(0, 3),
		numCell(0, 4, *r1, !blankPositions[4]),
		opCell(1, 0, op3),
		opCell(1, 2, op4),
		numCell(2, 0, c, !blankPositions[2]),
		opCell(2, 1, op2),
		numCell(2, 2, d, !blankPositions[3]),
		eqCell(2, 3),
		numCell(2, 4, *r2, !blankPositions[5]),
		eqCell(3, 0),
		eqCell(3, 2),
		numCell(4, 0, *r3, !blankPositions[6]),
		numCell(4, 2, *r4, !blankPositions[7]),
	}

	// Build answer and number pool
	var answerCells []AnswerCellData
	var numberPool []int
	for pos := range blankPositions {
		pk := posKeys[pos]
		answerCells = append(answerCells, AnswerCellData{Row: pk[0], Col: pk[1], Value: values[pos]})
		numberPool = append(numberPool, values[pos])
	}

	// Sort number pool
	for i := 0; i < len(numberPool); i++ {
		for j := i + 1; j < len(numberPool); j++ {
			if numberPool[j] < numberPool[i] {
				numberPool[i], numberPool[j] = numberPool[j], numberPool[i]
			}
		}
	}

	data := PuzzleData{
		GridRows:     5,
		GridCols:     5,
		Cells:        cells,
		NumberPool:   numberPool,
		TimeLimitSec: config.TimeLimitSec,
		HintCount:    1,
	}

	answer := PuzzleAnswer{Cells: answerCells}

	dataJSON, _ := json.Marshal(data)
	answerJSON, _ := json.Marshal(answer)

	return &GeneratedPuzzle{
		Data:         dataJSON,
		Answer:       answerJSON,
		TimeLimitSec: config.TimeLimitSec,
	}
}

func randNum(rng *rand.Rand, config LevelConfig) int {
	return config.MinNum + rng.Intn(config.MaxNum-config.MinNum+1)
}

func eval(a int, op string, b int) *int {
	var result int
	switch op {
	case "+":
		result = a + b
	case "-":
		result = a - b
	case "*":
		result = a * b
	case "/":
		if b == 0 || a%b != 0 {
			return nil
		}
		result = a / b
	default:
		return nil
	}
	return &result
}

func numCell(r, c, value int, given bool) CellData {
	var v any = value
	if !given {
		v = nil
	}
	return CellData{Row: r, Col: c, Type: "number", Value: v, Given: given}
}

func opCell(r, c int, op string) CellData {
	return CellData{Row: r, Col: c, Type: "op", Value: op, Given: true}
}

func eqCell(r, c int) CellData {
	return CellData{Row: r, Col: c, Type: "equals", Value: "=", Given: true}
}
