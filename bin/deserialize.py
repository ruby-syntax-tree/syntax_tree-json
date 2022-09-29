import io
import pathlib


class Location:
    def __init__(self, start_offset, end_offset):
        self.start_offset = start_offset
        self.end_offset = end_offset


class ArrayNode:
    def __init__(self, values, location):
        self.values = values
        self.location = location

    def __repr__(self):
        contents = ", ".join(map(repr, self.values))
        return f"[{contents}]"


class FalseNode:
    def __init__(self, location):
        self.location = location

    def __repr__(self):
        return "false"


class NullNode:
    def __init__(self, location):
        self.location = location

    def __repr__(self):
        return "null"


class NumberNode:
    def __init__(self, value, location):
        self.value = value
        self.location = location

    def __repr__(self):
        return self.value


class ObjectNode:
    def __init__(self, values, location):
        self.values = values
        self.location = location

    def __repr__(self):
        contents = ", ".join(f"{key}: {value}" for key, value in self.values)
        return f"{{ {contents} }}"


class RootNode:
    def __init__(self, value, location):
        self.value = value
        self.location = location

    def __repr__(self):
        return repr(self.value)


class StringNode:
    def __init__(self, value, location):
        self.value = value
        self.location = location

    def __repr__(self):
        return self.value


class TrueNode:
    def __init__(self, location):
        self.location = location

    def __repr__(self):
        return "true"


def deserialize(source, stream):
    directive = stream.read(1)
    location = Location(
        int.from_bytes(stream.read(8), "little"),
        int.from_bytes(stream.read(8), "little"),
    )

    if directive == b"A":
        length = int.from_bytes(stream.read(8), "little")
        values = [deserialize(source, stream) for _ in range(0, length)]
        return ArrayNode(values, location)
    elif directive == b"F":
        return FalseNode(location)
    elif directive == b"N":
        return NullNode(location)
    elif directive == b"#":
        return NumberNode(source[location.start_offset : location.end_offset], location)
    elif directive == b"O":
        length = int.from_bytes(stream.read(8), "little")
        values = [
            [deserialize(source, stream), deserialize(source, stream)]
            for _ in range(0, length)
        ]
        return ObjectNode(values, location)
    elif directive == b"R":
        return RootNode(deserialize(source, stream), location)
    elif directive == b"S":
        return StringNode(source[location.start_offset : location.end_offset], location)
    elif directive == b"T":
        return TrueNode(location)
    else:
        raise Exception(f"Invalid directive: {directive}")


if __name__ == "__main__":
    filepath = pathlib.Path(__file__).parent.parent.joinpath("test.json")

    with open(filepath, "r") as file:
        source = file.read()

    with open(f"{filepath}.ser") as file:
        serialized = file.read()

    stream = io.BytesIO(str.encode(serialized))
    assert stream.read(4) == b"STJN"
    assert int.from_bytes(stream.read(4), "little") == 0
    assert int.from_bytes(stream.read(4), "little") == 3
    assert int.from_bytes(stream.read(4), "little") == 0

    print(deserialize(source, stream))
